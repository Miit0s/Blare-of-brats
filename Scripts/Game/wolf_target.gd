extends Node3D
class_name WolfTarget

@onready var area_3d: Area3D = $Area3D
@onready var spot_light_3d: SpotLight3D = $SpotLight3D

@export var speed: float = 5

@export_category("Tween")
@export var distance_for_slow_down: float = 2
@export var slow_down_duration: float = 1
@export var distance_for_speed_up: float = 2
@export var speed_up_duration: float = 1

var _target_position: Vector3 = Vector3.ZERO
var _is_tracking: bool = false
var _has_reach_destination: bool = false
var _has_finish_restart_move: bool = true

var _slow_down_tween: Tween = null
var _speed_up_tween: Tween = null

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
	elif _has_finish_restart_move:
		global_position = global_position.move_toward(_target_position, delta * speed)

func set_new_target_position(new_position: Vector3):
	_target_position = new_position
	
	if _has_reach_destination:
		_restart_move()
	
	_has_reach_destination = false
	
	if _slow_down_tween:
		_slow_down_tween.kill()
		_slow_down_tween = null

func start_tracking():
	_is_tracking = true
	spot_light_3d.show()

func stop_tracking():
	_is_tracking = false
	spot_light_3d.hide()

func _restart_move():
	_has_finish_restart_move = false
	
	var point_ratio_to_destination: float = distance_for_speed_up / global_position.distance_to(_target_position)
	var speed_up_destination_point: Vector3 = lerp(global_position, _target_position, point_ratio_to_destination)
	
	_speed_up_tween = create_tween()
	_speed_up_tween.set_ease(Tween.EASE_IN)
	_speed_up_tween.set_trans(Tween.TRANS_QUAD)
	_speed_up_tween.tween_property(self, "global_position", speed_up_destination_point, slow_down_duration)
	_speed_up_tween.finished.connect(func():
		_has_finish_restart_move = true
		_speed_up_tween = null
	)
