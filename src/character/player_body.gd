extends CharacterBody3D

class_name PlayerBody


const MOVE_SPEED:float = 10.0
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
var primary_direction:Vector3
var previous_lookat:Vector3 = Vector3.ZERO


# Flags
var is_telegraphing:bool = false
var is_turning:bool = false
var is_right_down:bool = false
var is_jumping:bool = false
var is_active:bool :
	get: return is_instance_valid(character) and character.is_active


# Nodes
@onready var anchor:Node3D = $anchor
@onready var gizmo:Node3D = $anchor/gizmo
@onready var mesh:MeshInstance3D = $MeshInstance3D
@onready var camera:Camera3D = $anchor/gizmo/Camera3D
@onready var character = get_parent()


func _input(event):
	if not self.is_active: return
	
	if event is InputEventMouseMotion:
		mouse_delta = event.relative
		
		var y_lerp = deg_to_rad(-look_speed * mouse_delta.x)
		var x_lerp = deg_to_rad(look_speed * mouse_delta.y)
		
		# Rotate anchor/gizmo for camera rotation
		anchor.rotate_y(y_lerp)
		gizmo.rotate_x(x_lerp)
		gizmo.rotation.x = clamp(gizmo.rotation.x, -0.8, 0.8)


func process_input():
	if not self.is_active: return
	
	is_right_down = Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
	is_jumping = character.type == PlayableCharacter.Types.SPIRIT and Input.is_action_just_pressed("action")
	
	if Input.is_action_pressed("forward"):
		direction += facing[2]
		primary_direction = facing[2]
	elif Input.is_action_pressed("backward"):
		direction -= facing[2]
		primary_direction = -facing[2]
	else:
		primary_direction = Vector3.ZERO
	
	if Input.is_action_pressed("right"):
		if is_telegraphing: direction -= facing[0]
		else: direction = lerp(-facing[0], primary_direction, 0.5)
	if Input.is_action_pressed("left"):
		if is_telegraphing: direction += facing[0]
		else: direction =  lerp(facing[0], primary_direction, 0.5)


func _process(delta):
	facing = anchor.global_transform.basis
	
	direction = Vector3.ZERO
	turn_degrees = 0.0
	is_turning = false
	
	process_input()
	direction = direction.normalized()
		
	if direction.length() > 0:
		mesh_look(global_transform.origin + direction, delta)
		
	mouse_delta = Vector2.ZERO
	
	var destination = direction * move_speed
	var acceleration = DE_ACCELERATION
	
	var horizontal_velocity = velocity
	if direction.dot(horizontal_velocity) > 0:
		acceleration = ACCELERATION
		
	horizontal_velocity.y = 0
	horizontal_velocity = horizontal_velocity.lerp(destination, acceleration * delta)
	
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z
	velocity.y -= GRAVITY * delta
	
	if is_jumping and is_on_floor():
		velocity.y = JUMP_FORCE
	
	move_and_slide()


func mesh_look(origin:Vector3, delta:float) -> void:
	if not is_instance_valid(mesh): return
	
	var direction = global_transform.origin.direction_to(origin) * -2
	var lookat = global_transform.origin + Vector3(direction.x, 5, direction.z)
	var look_offset = (lookat - previous_lookat) * TURN_SPEED * delta
	
	previous_lookat += look_offset
	mesh.look_at(previous_lookat, Vector3.UP)
	mesh.rotation.x = 0
