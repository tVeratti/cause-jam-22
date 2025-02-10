extends CharacterBody3D


class_name PlayerCharacter


enum Types { FOX, SPIRIT }
enum Actions { JUMP, BREAK }


@export var type:Types = Types.FOX
@export var is_active:bool = false :
	set(value):
		is_active = value


var previous_lookat:Vector3 = Vector3.ZERO


@onready var controller:PlayerController = %PlayerController
@onready var swap_timer:Timer = $swap_timer

@onready var anchor:Node3D = %Anchor
@onready var gizmo:Node3D = %Gizmo
@onready var camera_anchor:Marker3D = %CameraAnchor
@onready var camera_lookat:Marker3D = %CameraLookAt
@onready var mesh:MeshInstance3D = %MeshInstance3D
@onready var material:StandardMaterial3D = mesh.get_active_material(0)


func _ready():
	Signals.swap.connect(self.swap)
	self.is_active = is_active
	

func _process(delta):
	if not is_active: return
	
	if swap_timer.is_stopped() and Input.is_action_just_pressed("swap"):
		Signals.swap.emit(type)


func _physics_process(delta):
	camera_anchor.look_at(camera_lookat.global_position)
	
	if not is_active: return
	
	velocity = controller.get_velocity(velocity, delta)
	
	var velocity_flat:Vector3 = Vector3(velocity.x, 0, velocity.z)
	if not velocity_flat.is_zero_approx():
		mesh_look(global_transform.origin + velocity_flat, delta)
		
	move_and_slide()


func mesh_look(origin:Vector3, delta:float) -> void:
	if not is_instance_valid(mesh): return
	
	var direction = global_transform.origin.direction_to(origin) * -2
	var lookat = global_transform.origin + Vector3(direction.x, 5, direction.z)
	var look_offset = (lookat - previous_lookat) * PlayerController.TURN_SPEED * delta
	
	previous_lookat += look_offset
	mesh.look_at(previous_lookat, Vector3.UP)
	mesh.rotation.x = 0


func swap(from_type:Types):
	self.is_active = from_type != type
	swap_timer.start()
	
	if is_active: on_swap_on()
	else: on_swap_off()


func on_swap_off():
	pass


func on_swap_on():
	Signals.character_swapped.emit(self)
