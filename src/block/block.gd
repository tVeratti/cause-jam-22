extends StaticBody3D


class_name Block


const SIZE:float = 2.0

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


var coords:Array = []
var is_breaking:bool = false
var color:Color = BlockColors.RED:
	set(value):
		color = value
		material.set_shader_parameter("color", value)


@onready var mesh:MeshInstance3D = $MeshInstance3D
@onready var outline_mesh:MeshInstance3D = %Outline
@onready var collision_shape:CollisionShape3D = $CollisionShape3D
@onready var bounce_area:Area3D = $bounce_area
@onready var animation_player:AnimationPlayer = $AnimationPlayer
@onready var material:ShaderMaterial = mesh.get_active_material(0)
@onready var audio_player:AudioStreamPlayer3D = $AudioStreamPlayer3D


func _ready():
	outline_mesh.hide()
	
	scale = Vector3(SIZE - 0.1, 1.0, SIZE - 0.1)


func _process(_delta):
	var character_fox = get_tree().get_nodes_in_group("fox")[0]
	var spirit_active = not character_fox.is_active
	
	var fox_distance = 999
	if is_breaking: fox_distance = 0.0
	elif spirit_active:
		var fox_origin = character_fox.global_transform.origin
		fox_distance = _ignore_y(global_transform.origin).distance_to(_ignore_y(fox_origin))
	
	material.set_shader_parameter("fox_distance", fox_distance)


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


func _start_break_animation() -> void:
	collision_shape.disabled = true
	bounce_area.monitorable = false
	bounce_area.monitoring = false
	
	var tween: = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(mesh, "scale", Vector3.ZERO, 0.2)
	tween.tween_callback(func():
		queue_free())


func _on_bounce_area_body_entered(body:CharacterSpirit):
	if body.can_bounce:
		body.bounce()
		animation_player.play("bounce")
		audio_player.play()
		swap_color(body)
