extends Node3D
class_name WolfTarget

@onready var area_3d: Area3D = $Area3D

@export var speed: float = 5
@export var distance_for_slow_down: float = 5
@export var slow_down_duration: float = 1

var _target_position: Vector3 = Vector3.ZERO
var _is_tracking: bool = false
var _has_reach_destination: bool = false

var _slow_down_tween: Tween = null

signal has_reach_destination

func _process(delta: float) -> void:
	if not _is_tracking: return
	
	if global_position.is_equal_approx(_target_position):
		_has_reach_destination = true
		has_reach_destination.emit()
	
	if global_position.distance_to(_target_position) <= distance_for_slow_down and _slow_down_tween == null:
		_slow_down_tween = create_tween()
		_slow_down_tween.set_ease(Tween.EASE_OUT)
		_slow_down_tween.set_trans(Tween.TRANS_QUAD)
		_slow_down_tween.tween_property(self, "global_position", _target_position, slow_down_duration)
	else:
		global_position = global_position.move_toward(_target_position, delta * speed)

func set_new_target_position(new_position: Vector3):
	_target_position = new_position
	_has_reach_destination = false
	
	if _slow_down_tween:
		_slow_down_tween.kill()
		_slow_down_tween = null

func start_tracking():
	_is_tracking = true

func stop_tracking():
	_is_tracking = false
