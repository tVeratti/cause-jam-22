extends Node3D


const BlockScene = preload("res://block/block.tscn")

const MAP_SIZE:int = 30
const BLOCK_MARGIN:float = 0.1

var maze:Array = []
var blocks_broken:int = 0
var checked_coords:Array = []


func _ready():
	generate_maze()

	BlockManager.try_break.connect(check_break)
	

func generate_maze() -> void:
	randomize()
	var maze_origin: = global_transform.origin
	
	for x in range(MAP_SIZE):
		maze.append([])
		for y in range(MAP_SIZE):
			var block = BlockScene.instantiate()
			add_child(block)
			block.coords = [x, y]
			block.color = get_random_color(x, y)
			
			var block_margin: = Vector3(x, 0.0, y) * BLOCK_MARGIN
			var block_offset: = Vector3(
				x * Block.SIZE,
				Block.SIZE * 0.33,
				y * Block.SIZE)
			
			block.global_transform.origin = maze_origin + block_offset + block_margin
			
			maze[x].append(block)


func get_random_color(x:int, y:int) -> Color:
	var adjacent_colors = get_adjacent_colors(x, y)
	if adjacent_colors.size() > 0:
		var random_index = randi_range(0, adjacent_colors.size() - 1)
		return adjacent_colors[random_index]
	else:
		var value = randi_range(0, 5)
		match(value):
			0: return BlockColors.RED
			1: return BlockColors.BLUE
			2: return BlockColors.YELLOW
			3: return BlockColors.ORANGE
			4: return BlockColors.GREEN
			_: return BlockColors.PURPLE


func get_adjacent_colors(x:int, y:int) -> Array:
	var adjacent_colors = [
		BlockColors.RED,
		BlockColors.BLUE,
		BlockColors.YELLOW,
		BlockColors.ORANGE,
		BlockColors.GREEN,
		BlockColors.PURPLE]
	
	for offset_x in range(2):
		for offset_y in range(2):
			var block_x = x - offset_x
			var block_y = y - offset_y
			if block_x < 0 or block_y < 0 or (block_y == y and block_x == x): continue
			
			var adjacent_block = maze[block_x][block_y]
			if is_instance_valid(adjacent_block):
				var adjacent_color = adjacent_block.color
				if adjacent_colors.has(adjacent_color):
					adjacent_colors.erase(adjacent_color)
	
	return adjacent_colors


func check_break(block:Block, player:PlayerCharacter) -> Array:
	var x = block.coords[0]
	var y = block.coords[1]
	
	checked_coords = []
	var connected_coords:Array = get_connections(x, y, [], block.color)
	
	# Sort blocks by distance to player so the nearest breaks first.
	var player_position:Vector3 = player.global_position
	connected_coords.sort_custom(func(a:Vector2, b:Vector2):
		var block_a:Block = maze[a.x][a.y]
		var block_b:Block = maze[b.x][b.y]
		if block_a == block: return true
		elif block_b == block: return false
		
		return block_a.global_position.distance_to(player_position) < block_b.global_position.distance_to(player_position))
	
	Signals.add_points.emit(connected_coords.size())
	
	for breakable_coord in connected_coords:
		var breakable_block = maze[breakable_coord.x][breakable_coord.y]
		
		await get_tree().create_timer(0.1).timeout
		breakable_block.break_self(blocks_broken)
		blocks_broken += 1
	
	return connected_coords


func get_connections(x, y, current_connections, color) -> Array:
	if checked_coords.has(Vector2(x, y)): return current_connections
	checked_coords.append(Vector2(x, y))
	
	var adjacent_coords = get_adjacent_coords(x, y, color)
	for connection in adjacent_coords:
			if not current_connections.has(connection):
				current_connections.append(connection)
	
	for coords in adjacent_coords:
		var connections = get_connections(coords.x, coords.y, current_connections, color)
		for connection in connections:
			if not current_connections.has(connection):
				current_connections.append(connection)
	
	return current_connections


func get_adjacent_coords(x:int, y:int, target_color:Color) -> Array:
	var coords:Array = []
	
	for offset_x in range(3):
		for offset_y in range(3):
			var block_x = x + (offset_x - 1)
			var block_y = y + (offset_y - 1)
			# no diagonal checks
			if Vector2(x, y).distance_to(Vector2(block_x, block_y)) > 1: continue
			# valid block and not this one
			if block_x < 0 or block_y < 0 or (block_y == y and block_x == x): continue
			
			var adjacent_block = maze[block_x][block_y]
			if is_instance_valid(adjacent_block):
				var adjacent_color = adjacent_block.color
				if adjacent_color == target_color:
					coords.append(Vector2(block_x, block_y))
		
	return coords
