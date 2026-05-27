@tool
extends Item

@export var min_collision_range: float = 0.5
@export var max_collision_range: float = 4

@onready var begin_collision_shape_position: Vector3 = attack_collision_shape_3d.position

func _perform_attack(_direction: Vector3):
	var attack_collision_shape_size: Vector3 = attack_collision_shape_3d.shape.size
	
	attack_collision_shape_3d.shape.size.x = min_collision_range
	
	var extends_hitbox_tween: Tween = create_tween()
	extends_hitbox_tween.tween_property(
		attack_collision_shape_3d.shape,
		"size",
		Vector3(max_collision_range, attack_collision_shape_size.y, attack_collision_shape_size.z),
		attack_speed
	)
	extends_hitbox_tween.parallel().tween_method(
		_reset_collision_to_correct_position,
		min_collision_range,
		max_collision_range,
		attack_speed
	)
	
	animated_sprite_3d.play()

func _reset_collision_to_correct_position(collision_x_size: int):
	attack_collision_shape_3d.position.x = begin_collision_shape_position.x - max_collision_range - collision_x_size
