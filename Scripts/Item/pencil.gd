@tool
extends Item

func _perform_attack(direction: Vector3):
	gpu_trail_3d.show()
	gpu_trail_3d.length = 100
	
	await get_tree().create_timer(attack_speed).timeout
	_attacked_players = []
	gpu_trail_3d.hide()
	gpu_trail_3d.length = 0
