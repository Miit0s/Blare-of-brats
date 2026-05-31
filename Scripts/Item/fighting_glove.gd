extends Item

@export var min_collision_range: float = 0.5
@export var max_collision_range: float = 4

var _extends_hitbox_tween: Tween = null

func _ready() -> void:
	super._ready()
	
	attack_collision_shape_3d.shape.size.x = min_collision_range

func _physics_process(_delta: float) -> void:
	super._physics_process(_delta)
	
	attack_collision_shape_3d.position.x = attack_collision_shape_3d.shape.size.x / 2

func _perform_attack(_direction: Vector3):
	var attack_collision_shape_size: Vector3 = attack_collision_shape_3d.shape.size
	
	_extends_hitbox_tween = create_tween()
	_extends_hitbox_tween.tween_property(
		attack_collision_shape_3d.shape,
		"size",
		Vector3(max_collision_range, attack_collision_shape_size.y, attack_collision_shape_size.z),
		attack_speed
	)
	animated_sprite_3d.speed_scale = animated_sprite_3d.sprite_frames.get_frame_count("default") / attack_speed
	animated_sprite_3d.play()
	
	await _extends_hitbox_tween.finished
	attack_collision_shape_3d.shape.size.x = min_collision_range
	_extends_hitbox_tween = null

func item_picked_up(player_id: int):
	super.item_picked_up(player_id)
	
	animated_sprite_3d.rotate_x(deg_to_rad(-90))

func _attack_player(player_hit: Player):
	current_durability -= 1
	super._attack_player(player_hit)

func cancel_animation():
	super.cancel_animation()
	
	if _extends_hitbox_tween:
		_extends_hitbox_tween.kill()
		attack_collision_shape_3d.shape.size.x = min_collision_range
