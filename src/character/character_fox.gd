extends PlayerCharacter


class_name CharacterFox


var focused_block:Block


@onready var break_ray:RayCast3D = %BreakRay



func _ready():
	is_active = true
	_on_swap_on()
	
	super._ready()


func _process(delta):
	super._process(delta)
	
	if not is_active: return
	
	# Point BreakRay based on camera rotation
	break_ray.global_rotation.y = camera_anchor.global_rotation.y
	
	if break_ray.is_colliding():
		var colliding_block:Block = break_ray.get_collider() as Block
		_focus_block(colliding_block)
	else:
		_unfocus_block()
	
	if Input.is_action_just_pressed("action"):
		if is_instance_valid(focused_block):
			BlockManager.try_break.emit(focused_block, self)


func _focus_block(new_block:Block) -> void:
	if new_block == focused_block: return
	
	_unfocus_block()
	
	if is_instance_valid(new_block):
		focused_block = new_block
		focused_block.show_outline(true)


func _unfocus_block() -> void:
	if is_instance_valid(focused_block):
		focused_block.show_outline(false)
		focused_block = null
