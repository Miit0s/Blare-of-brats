extends Item

@onready var pistogum_explosion: AnimatedSprite3D = $PistogumExplosion
@onready var pistogum_trail: AnimatedSprite3D = $PistogumTrail

@export var player_speed_multiplier: float = 0.5
@export var slow_duration: float = 1

@export_category("Vibration")
@export_group("On Shoot")
@export_range(0, 1) var vibration_force_on_shoot: float = 0.8
@export var vibration_duration_on_shoot: float = 0.1
@export_category("Tween")
@export var trail_effect_distance: float = 20

func _perform_attack(_direction: Vector3):
	current_durability -= 1
	
	pistogum_explosion.global_position = self.global_position
	pistogum_trail.global_position = self.global_position
	pistogum_trail.look_at(self.global_position - self.global_basis.z)
	pistogum_trail.global_rotation.y += deg_to_rad(90)
	pistogum_trail.global_rotation.x += deg_to_rad(90)
	
	var forward_direction: Vector3 = -global_transform.basis.z
	var target_position: Vector3 = self.global_position + (forward_direction * trail_effect_distance)
	
	var trail_tween: Tween = create_tween()
	trail_tween.set_ease(Tween.EASE_OUT)
	trail_tween.set_trans(Tween.TRANS_QUAD)
	trail_tween.tween_property(pistogum_trail, "global_position", target_position, attack_speed)
	
	pistogum_explosion.play("default")
	pistogum_trail.play("default")
	
	VibrationManager.start_joy_vibration(owner_player, vibration_force_on_shoot, 0, vibration_duration_on_shoot)

func _attack_player(player_hit: Player):
	player_hit.apply_slow(player_speed_multiplier, slow_duration)
	super._attack_player(player_hit)
