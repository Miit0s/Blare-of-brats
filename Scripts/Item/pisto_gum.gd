extends Item

@onready var pisto_gum_shoot: GPUParticles3D = $PistoGumShoot

@export var player_speed_multiplier: float = 0.5
@export var slow_duration: float = 1

@export_category("Vibration")
@export_group("On Shoot")
@export_range(0, 1) var vibration_force_on_shoot: float = 0.8
@export var vibration_duration_on_shoot: float = 0.1

func _perform_attack(_direction: Vector3):
	current_durability -= 1
	pisto_gum_shoot.restart()
	VibrationManager.start_joy_vibration(owner_player, vibration_force_on_shoot, 0, vibration_duration_on_shoot)

func _attack_player(player_hit: Player):
	player_hit.apply_slow(player_speed_multiplier, slow_duration)
	super._attack_player(player_hit)
