extends Item

func _perform_attack(_direction: Vector3):
	pass

func _process(_delta: float) -> void:
	super._process(_delta)

func _attack_player(player_hit: Player):
	current_durability -= 1
	super._attack_player(player_hit)
