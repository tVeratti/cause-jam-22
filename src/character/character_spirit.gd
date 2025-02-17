extends PlayerCharacter


class_name CharacterSpirit


const LAUNCH_FACING_MULTIPLIER:float = 20.0
const LAUNCH_VELOCITY:Vector3 = Vector3(0, 10, 0)
const DECAL_SIZE:Vector3 = Vector3(0.5, 0.5, 0.5)


var color:Color = BlockColors.BLUE :
	set(value):
		color = value
		material.albedo_color = value

var can_bounce:bool :
	get():
		return bounce_timer.is_stopped()

@onready var bounce_timer:Timer = $BounceTimer
@onready var shadow_raycast:RayCast3D = %ShadowRayCast
@onready var shadow_decal:Decal = %ShadowDecal

#@onready var particles:CPUParticles3D = $player_body/CPUParticles3D
#@onready var audio:AudioStreamPlayer3D = $player_body/AudioStreamPlayer3D


func bounce() -> void:
	if bounce_timer.is_stopped():
		bounce_timer.start()
		velocity.y = PlayerController.JUMP_FORCE


func _process(delta):
	super._process(delta)
	
	if shadow_raycast.is_colliding():
		var block:Block = shadow_raycast.get_collider()
		shadow_decal.global_position = shadow_raycast.get_collision_point()
		var distance: = shadow_decal.global_position.distance_to(global_position)
		var distance_percentage = max(0.3, 1.0 - (distance / 3.0))
		shadow_decal.size = DECAL_SIZE * distance_percentage


func _on_swap_on():
	var fox_body = get_tree().get_first_node_in_group("fox")
	var facing = fox_body.anchor.basis.z.normalized()
	global_transform.origin = fox_body.global_transform.origin + Vector3.UP
	velocity = (facing * LAUNCH_FACING_MULTIPLIER) + LAUNCH_VELOCITY
	#particles.emitting = true
	#audio.play()
	
	show()
	super._on_swap_on()


func _on_swap_off():
	global_transform.origin = Vector3.ZERO
	hide()


func _on_reset_check_body_entered(body):
	Signals.swap.emit(type)
