extends PlayerCharacter


@onready var break_ray:RayCast3D = %BreakRay



func _ready():
	is_active = true
	on_swap_on()
	
	super._ready()


func _process(delta):
	super._process(delta)
	
	if not is_active: return
	
	# Point BreakRay based on camera rotation
	break_ray.global_rotation.y = camera_anchor.global_rotation.y
	
	if Input.is_action_just_pressed("action"):
		if break_ray.is_colliding():
			var block = break_ray.get_collider().get_parent()
			if is_instance_valid(block) and block.has_method("break_self"):
				BlockManager.try_break.emit(block, self)
