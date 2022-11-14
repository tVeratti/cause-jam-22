extends Node

class_name PlayableCharacter

enum Types { FOX, SPIRIT }
enum Actions { JUMP, BREAK }

@export var type:Types = Types.FOX
@export var is_active:bool = false :
	set(value):
		is_active = value
		if is_instance_valid(camera):
			camera.current = value


@onready var player_body:CharacterBody3D = $player_body
@onready var swap_timer:Timer = $swap_timer
@onready var camera:Camera3D = player_body.camera


func _ready():
	Signals.swap.connect(self.swap)
	self.is_active = is_active
	

func _process(delta):
	if not is_active: return
	
	if swap_timer.is_stopped() and Input.is_action_just_pressed("swap"):
		Signals.swap.emit(type)


func swap(from_type:Types):
	self.is_active = from_type != type
	swap_timer.start()
