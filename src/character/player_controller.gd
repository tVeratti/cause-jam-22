extends Node

class_name PlayerController


const MOVE_SPEED:float = 8.0
const TURN_SPEED:float = 10.0
const LOOK_SPEED:float = 0.1
const ACCELERATION:float = 5.0
const DE_ACCELERATION:float = 8.0
const TURN_MOVE_MULTIPLIER = 0.5
const JUMP_FORCE = 11.0
const GRAVITY = 30.0


# Variables
var move_speed:float = MOVE_SPEED
var look_speed:float = LOOK_SPEED
var direction:Vector3 = Vector3.ZERO
var facing:Basis = Basis()
var turn_degrees:float = 0.0
var mouse_delta:Vector2 = Vector2.ZERO


# Flags
var is_jumping:bool = false
var is_active:bool :
	get: return is_instance_valid(character) and character.is_active


# Nodes
@onready var anchor:Node3D = %Anchor
@onready var gizmo:Node3D = %Gizmo
@onready var character:PlayerCharacter = get_parent()


func _input(event):
	#if not self.is_active: return
	
	if event is InputEventMouseMotion:
		mouse_delta = event.relative
		
		var y_lerp = deg_to_rad(-look_speed * mouse_delta.x)
		var x_lerp = deg_to_rad(look_speed * mouse_delta.y)
		
		# Rotate anchor/gizmo for camera rotation
		anchor.rotate_y(y_lerp)
		gizmo.rotate_x(x_lerp)
		gizmo.rotation.x = clamp(gizmo.rotation.x, -0.8, 0.8)


func _process(delta):
	mouse_delta = Vector2.ZERO


func _get_direction() -> Vector3:
	var facing: = anchor.global_transform.basis
	
	#character.type == PlayableCharacter.Types.SPIRIT
	var move_direction: = Vector3.ZERO
	var facing_direction: = Vector3.ZERO
	
	if Input.is_action_pressed("forward"):
		facing_direction = facing[2]
		move_direction = facing[2]
	elif Input.is_action_pressed("backward"):
		facing_direction = -facing[2]
		move_direction = -facing[2]
	else:
		move_direction = Vector3.ZERO
	
	if Input.is_action_pressed("left"):
		move_direction = lerp(+facing[0], facing_direction, 0.5)
	if Input.is_action_pressed("right"):
		move_direction = lerp(-facing[0], facing_direction, 0.5)
	
	return move_direction.normalized()


func get_velocity(velocity:Vector3, delta:float) -> Vector3:
	direction = _get_direction()
	
	var destination: = direction * move_speed
	var acceleration: = DE_ACCELERATION
	
	var horizontal_velocity:Vector3 = velocity
	if direction.dot(horizontal_velocity) > 0:
		acceleration = ACCELERATION
		
	horizontal_velocity.y = 0
	horizontal_velocity = horizontal_velocity.lerp(destination, acceleration * delta)
	
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z
	velocity.y -= GRAVITY * delta
	
	if is_jumping and character.is_on_floor():
		velocity.y = JUMP_FORCE
	
	return velocity
