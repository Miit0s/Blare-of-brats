@tool
extends Item

@export var min_collision_range: float = 0.5
@export var max_collision_range: float = 4

func _perform_attack(direction: Vector3):
	var attack_collision_shape_size: Vector3 = attack_collision_shape_3d.shape.size
	
	attack_collision_shape_3d.shape.size.x = min_collision_range
	
	var extends_hitbox_tween: Tween = create_tween()
	extends_hitbox_tween.tween_property(
		attack_collision_shape_3d.shape,
		"size",
		Vector3(max_collision_range, attack_collision_shape_size.y, attack_collision_shape_size.z),
		attack_speed
	)
	
	
	animated_sprite_3d.play()
