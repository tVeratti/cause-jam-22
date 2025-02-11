extends Node


const BLOCK_POINTS:float = 1.0
const COMBO_MULTIPLIER:float = 2.0
const COMBO_MINIMUM:int = 2


var points:float = 0.0
var start_time:float = Time.get_ticks_msec()


@onready var character_fox = $CharacterFox
@onready var character_spirit = $CharacterSpirit


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Signals.add_points.connect(self.add_points)


func add_points(num_blocks:int):
	points += BLOCK_POINTS * num_blocks
	if num_blocks >= COMBO_MINIMUM:
		var num_combos = int(num_blocks / COMBO_MINIMUM)
		var bonus_points = num_combos * COMBO_MULTIPLIER
		points += bonus_points
		
		var index = 1
		for bonus in range(num_combos):
			Signals.bonus_earned.emit(index)
			await get_tree().create_timer(0.2).timeout
			index += 1
	
	Signals.points_changed.emit(points)


func _on_ground_area_body_entered(body):
	if body.get_parent() == character_spirit and is_instance_valid(character_spirit):
		Signals.swap.emit(PlayerCharacter.Types.SPIRIT)
