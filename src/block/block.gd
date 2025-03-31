extends StaticBody3D


class_name Block


const SIZE:float = 3.0

const BREAK_ROTATION:float = 45 #degrees

# Break Notes
const NOTE_1 = preload("res://block/assets/sounds/Note1.wav")
const NOTE_2 = preload("res://block/assets/sounds/Note2.wav")
const NOTE_3 = preload("res://block/assets/sounds/Note3.wav")
const NOTE_4 = preload("res://block/assets/sounds/Note4.wav")
const NOTE_5 = preload("res://block/assets/sounds/Note5.wav")
const NOTE_6 = preload("res://block/assets/sounds/Note6.wav")
const BREAK_NOTES = [
	NOTE_1,
	NOTE_2,
	NOTE_3,
	NOTE_4,
	NOTE_5,
	NOTE_6,
	NOTE_5,
	NOTE_4,
	NOTE_3,
	NOTE_2]

const ROTATION_SPEED:float = 2.0
const ROTATIONS:Array = [
	Vector3(90, 0, 0),
	Vector3(180, 0, 0),
	Vector3(-90, 0, 0),
	Vector3(0, 0, 0),
	Vector3(0, 0, 90),
	Vector3(0, 0, -90)
]

var coords:Array = []
var is_breaking:bool = false

var current_shape:BlockTypes.Shapes
var color:Color = BlockColors.RED: set = _set_color


@onready var mesh_root:Node3D = %MeshRoot
@onready var sides_root:Node3D = %Sides
@onready var outline_mesh:MeshInstance3D = %Outline
@onready var collision_shape:CollisionShape3D = $CollisionShape3D
@onready var bounce_area:Area3D = $bounce_area
@onready var animation_player:AnimationPlayer = $AnimationPlayer
@onready var audio_player:AudioStreamPlayer3D = $AudioStreamPlayer3D


func _ready():
	outline_mesh.hide()
	for side in sides_root.get_children():
		side.material_override = side.get_active_material(0).duplicate()
	
	call_deferred("_set_sides_color")
	
	scale = Vector3(SIZE, SIZE, SIZE)


func _process(delta):
	var character_fox = get_tree().get_nodes_in_group("fox")[0]
	var spirit_active = not character_fox.is_active
	
	var player_distance = 999
	if is_breaking: player_distance = 0.0
	elif spirit_active:
		var fox_origin = character_fox.global_transform.origin
		player_distance = _ignore_y(global_transform.origin).distance_to(_ignore_y(fox_origin))
	
	_set_sides_distance(player_distance)


func show_outline(do_show:bool = true) -> void:
	if do_show: outline_mesh.show()
	else: outline_mesh.hide()


func _ignore_y(vector:Vector3) -> Vector3:
	return Vector3(vector.x, 0, vector.z)


func swap_color(character) -> void:
	var temp_color:Color = character.color
	character.color = color
	self.color = temp_color


func break_self(index:int = 0) -> void:
	is_breaking = true
	call_deferred("_start_break_animation")
	
	audio_player.stream = BREAK_NOTES[index % BREAK_NOTES.size() - 1]
	audio_player.bus = "Break"
	audio_player.play()


func _set_sides_color() -> void:
	var index:int = 0
	for side in sides_root.get_children():
		_set_side_params(index)
		index += 1
	
	var tween: = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	
	var target_rotation:Vector3 = ROTATIONS[current_shape]
	var current_rotation:Vector3 = mesh_root.rotation_degrees
	var rotation_distance: = target_rotation.distance_to(current_rotation)
	var tween_duration:float = 0.6
	
	#if target_rotation.x != current_rotation.x:
	tween.tween_property(mesh_root, "scale", Vector3(0.9, 0.9, 0.9), tween_duration / 2)
	tween.parallel().tween_property(mesh_root, "rotation_degrees", target_rotation, tween_duration).set_delay(0.1)
	tween.tween_property(mesh_root, "scale", Vector3.ONE, tween_duration / 2)
	
	#if target_rotation.z != current_rotation.z:
		#tween.parallel().tween_property(mesh_root, "rotation_degrees:z", target_rotation.z, tween_duration)


func _set_sides_distance(distance:float) -> void:
	for side in sides_root.get_children():
		side.get_active_material(0).set_shader_parameter("player_distance", distance)


func _set_side_params(index:int) -> void:
	var shape:BlockTypes.Shapes = BlockTypes.Shapes.values()[index]
	var shape_texture: = BlockTypes.get_normal_texture_by_shape(shape)
	
	var side_mesh:MeshInstance3D = sides_root.get_child(index)
	var side_material:ShaderMaterial = side_mesh.get_active_material(0)
	side_material.set_shader_parameter("color", color)
	side_material.set_shader_parameter("shape_texture", shape_texture)


func _start_break_animation() -> void:
	collision_shape.disabled = true
	bounce_area.monitorable = false
	bounce_area.monitoring = false
	queue_free()
	
	#tween.tween_callback(func():
		#queue_free())


func _on_bounce_area_body_entered(body:CharacterSpirit):
	if body.can_bounce:
		body.bounce()
		animation_player.play("bounce")
		audio_player.play()
		swap_color(body)


func _set_color(value:Color) -> void:
	color = value
	current_shape = BlockTypes.get_shape_by_color(color)
	
	_set_sides_color()
