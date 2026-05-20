@tool
extends Item

func _perform_attack(direction: Vector3):
	current_durability -= 1
	
	var new_munition: Munition = munition_prefab.instantiate()
	new_munition.direction = _attack_direction
	new_munition.damage = damage
	new_munition.speed = munition_speed
	new_munition.position = global_position
	
	add_child(new_munition)
	
	sound_made.emit(sound_on_attack)
