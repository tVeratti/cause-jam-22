extends Camera3D


class_name MainCamera


const FOV_MAX:float = 90
const FOV_MIN:float = 40
const FOV_SPEED:float = 1.0
const MOVE_SPEED:float = 50.0
const MOVE_SPEED_CINEMATIC:float = 2.0
const LOOK_SPEED:float = 5.0

const SHAKE_STRENGTH_HARD:float = 30.0
const SHAKE_STRENGTH_SOFT:float = 10.0
const SHAKE_FADE:float = 5.0


@export var target:Node3D
var target_anchor:Node3D
var target_lookat:Node3D
var target_offset:Vector3 = Vector3.ZERO

var target_fov:float = FOV_MAX
var move_speed:float = MOVE_SPEED
var look_speed:float = LOOK_SPEED

var shake_offset:Vector3
var shake_current:float = 0.0



func _ready():
	
	CameraManager.camera = self
	
	CameraManager.shake_hard.connect(_on_shake_hard)
	CameraManager.shake_soft.connect(_on_shake_soft)
	
	Signals.character_swapped.connect(_on_character_swapped)


func _physics_process(delta):
	if is_instance_valid(target_anchor):
		global_position = lerp(global_position, target_anchor.global_position + target_offset, delta * move_speed)
		var lookat_position: = _get_lookat_target(target_lookat).global_position
		look_at(lookat_position)
	
	if shake_current > 0:
		shake_current = lerp(shake_current, 0.0, SHAKE_FADE * delta)
		shake_offset = _generate_shake()
	
	if abs(fov - target_fov) > 1.0:
		fov = lerp(fov, target_fov, delta * FOV_SPEED)


func shake(strength:float) -> void:
	shake_current = strength


func _generate_shake() -> Vector3:
	return Vector3(
		Random.roll_float(shake_current, -shake_current),
		Random.roll_float(shake_current, -shake_current),
		Random.roll_float(shake_current, -shake_current))



func _on_shake_hard() -> void:
	shake(SHAKE_STRENGTH_HARD)


func _on_shake_soft() -> void:
	shake(SHAKE_STRENGTH_SOFT)


func _on_character_swapped(new_character:PlayerCharacter) -> void:
	var distance: = target.global_position.distance_to(new_character.global_position)
	var direction: = target.global_position.direction_to(new_character.global_position)
	
	var direction_away:Vector3 = global_position.direction_to(target.global_position).cross(global_position.direction_to(new_character.global_position))
	target_offset = direction_away * 10
	
	var mid_point: = direction * (distance / 2.0)
	var end_point: = _get_lookat_target(new_character).global_position
	var tween_duration:float = max((MOVE_SPEED_CINEMATIC / distance) * 2.0, 0.3)
	var tween_duration_half: = tween_duration
	
	target =  new_character
	target_anchor = _get_anchor_target(target)
	target_lookat = _get_lookat_target(target)
	
	#var temp_lookat_anchor = Node3D.new()
	#add_child(temp_lookat_anchor)
	#temp_lookat_anchor.top_level = true
	#temp_lookat_anchor.global_position = target_lookat.global_position
	
	# Have the camera follow this node temporarily
	#target_lookat = temp_lookat_anchor
	
	var tween: = get_tree().create_tween()
	tween.tween_property(self, "target_fov", FOV_MAX, tween_duration_half)
	#tween.parallel().tween_property(temp_lookat_anchor, "global_position", end, tween_duration_half)
	tween.tween_property(self, "target_fov", target_fov, tween_duration_half)
	#tween.parallel().tween_property(temp_lookat_anchor, "global_position", end_point, tween_duration_half)
	tween.tween_callback(func():
		move_speed = MOVE_SPEED
		print("?", move_speed)
		
		# Now update the lookat target!
		target_lookat = _get_lookat_target(target)
		target_offset = Vector3.ZERO)
	
	move_speed = MOVE_SPEED_CINEMATIC


func _get_anchor_target(next_target:Node3D) -> Node3D:
	if is_instance_valid(next_target):
		if "camera_anchor" in next_target:
			return next_target.camera_anchor
		
	return next_target


func _get_lookat_target(next_target:Node3D) -> Node3D:
	if is_instance_valid(next_target):
		if "camera_lookat" in next_target:
			return next_target.camera_lookat
	
	return next_target
