extends Node


# grid of blocks that block movement
# enter "spirit world" where you can see their colors and line up 3 of a kind to break them and create a path


@onready var character_fox = $character_fox
@onready var character_spirit = $character_spirit


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
