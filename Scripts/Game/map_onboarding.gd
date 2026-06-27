extends MapScene
class_name MapOnboarding

@export var first_walls_to_move: Array[Node3D]
@export var second_walls_to_move: Array[Node3D]

var wall_down_by: float = 2
var wall_down_duration: float = 1.2

func move_down_first_walls():
	_move_down_walls(first_walls_to_move)

func move_down_second_walls():
	_move_down_walls(second_walls_to_move)

func _move_down_walls(walls_to_move: Array[Node3D]):
	var move_down_tween: Tween = create_tween()
	move_down_tween.set_ease(Tween.EASE_IN)
	move_down_tween.set_trans(Tween.TRANS_CUBIC)
	
	for wall in walls_to_move:
		var final_pos: Vector3 = Vector3(wall.global_position.x, wall.global_position.y - wall_down_by, wall.global_position.z)
		move_down_tween.parallel().tween_property(wall, "global_position", final_pos, wall_down_duration)
