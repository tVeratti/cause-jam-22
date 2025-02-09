extends Node


class_name Random


static func roll(maximum:int, minimum:int = 0) -> int:
	randomize()
	return int(randf_range(minimum, maximum)) # int() rounds down


static func roll_float(maximum:float, minimum:float = 0) -> float:
	randomize()
	return randf_range(minimum, maximum)


static func roll_check(target:int, maximum:int = 100) -> bool:
	var result = roll(maximum)
	return result >= target
