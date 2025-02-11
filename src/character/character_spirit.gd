extends PlayerCharacter


class_name CharacterSpirit


var color:Color = BlockColors.BLUE:
	set(value):
		color = value
		material.albedo_color = value


@onready var bounce_timer:Timer = $BounceTimer
#@onready var material:StandardMaterial3D = $player_body/MeshInstance3D.get_active_material(0)
#@onready var particles:CPUParticles3D = $player_body/CPUParticles3D
#@onready var audio:AudioStreamPlayer3D = $player_body/AudioStreamPlayer3D


func bounce() -> void:
	if bounce_timer.is_stopped():
		bounce_timer.start()
		velocity.y = PlayerController.JUMP_FORCE


func on_swap_on():
	var fox_body = get_tree().get_first_node_in_group("fox")
	var facing = fox_body.anchor.basis.z.normalized()
	global_transform.origin = fox_body.global_transform.origin + Vector3(0, 1, 0)
	velocity = (facing * 20) + Vector3(0, 10, 0)
	#anchor.rotation = fox_body.anchor.rotation
	#gizmo.rotation = fox_body.gizmo.rotation
	#particles.emitting = true
	#audio.play()
	
	super.on_swap_on()


func on_swap_off():
	global_transform.origin = Vector3.ZERO
	hide()
