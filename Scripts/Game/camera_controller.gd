extends Node3D
class_name CameraController

@export var margin: float = 2.0
@export var interpolation_speed: float = 5.0
@export var min_distance: float = 10.0
@export var reset_position_duration: float = 1.5

var players: Array[Player]
var _start_focus: bool = false

var _initial_offset: Vector3
var _start_position: Vector3

func _ready() -> void:
	_start_position = global_position

func _process(delta: float) -> void:
	if players.is_empty() or not _start_focus: return
	
	var center: Vector3 = _get_players_center()
	var distance: float = _get_max_distance()
	
	var zoom_factor: float = max(distance, min_distance)
	var target_position: Vector3 = center + _initial_offset.normalized() * (zoom_factor + margin)
	
	global_position = global_position.lerp(target_position, interpolation_speed * delta)

func add_player(new_player: Player):
	players.append(new_player)

func start_tracking():
	_start_focus = true
	_initial_offset = position - _get_players_center()

func stop_tracking():
	_start_focus = false
	players.clear()
	
	var reset_tween: Tween = create_tween()
	reset_tween.set_ease(Tween.EASE_OUT)
	reset_tween.set_trans(Tween.TRANS_BACK)
	reset_tween.tween_property(self, "global_position", _start_position, reset_position_duration)

func _get_players_center() -> Vector3:
	var average: Vector3 = Vector3.ZERO
	for player in players:
		average += player.feet.global_position
	return average / players.size()

func _get_max_distance() -> float:
	var bounds: AABB = AABB(players[0].feet.global_position, Vector3.ZERO)
	for player in players:
		bounds = bounds.expand(player.feet.global_position)
	return bounds.get_longest_axis_size()
