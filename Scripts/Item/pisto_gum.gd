extends Item

@onready var pisto_gum_shoot: GPUParticles3D = $PistoGumShoot

@export var player_speed_multiplier: float = 0.5
@export var slow_duration: float = 1

func _perform_attack(_direction: Vector3):
	current_durability -= 1
	pisto_gum_shoot.restart()

func _attack_player(player_hit: Player):
	super._attack_player(player_hit)
	
	player_hit.apply_slow(player_speed_multiplier)
	await get_tree().create_timer(slow_duration).timeout
	player_hit.apply_slow(1)
