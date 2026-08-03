extends Control
class_name GameSoundBar

@onready var sound_bar_animation: AnimatedSprite2D = $Mask/SoundBarAnimation

@export var target_value_sync_speed: float = 0.005
@export var number_of_lock_area: int = 3
@export var shrink_speed: float = 0.005

var sound_bar_max_volume: float = 100

var _game_sound_bar_volume: float = 0:
	set(new_value):
		_game_sound_bar_volume = clampf(new_value, 0.0, 1.0)
		sound_bar_animation.material.set_shader_parameter("progress", _game_sound_bar_volume)

var _target_value: float = 0
var _lock_sound_bar: bool = false
var _has_reach_target_value: bool = true
var _current_lock_area: int = 0

signal sound_bar_fill
signal lock_area_pass(lock_phase: int)

func _ready() -> void:
	sound_bar_animation.self_modulate = Color(1.0, 1.0, 1.0, 1.0)

func _process(delta: float) -> void:
	if _lock_sound_bar: return
	
	if _game_sound_bar_volume >= 1.0:
		_lock_sound_bar = true
		sound_bar_fill.emit()
	
	if _game_sound_bar_volume < _target_value and not _has_reach_target_value:
		_game_sound_bar_volume = move_toward(_game_sound_bar_volume, _target_value, target_value_sync_speed * delta)
	else:
		_has_reach_target_value = true
		var value_to_reach: float = _get_last_lock_area_passed() / sound_bar_max_volume
		_game_sound_bar_volume = move_toward(_game_sound_bar_volume, value_to_reach, shrink_speed * delta)
	TelemetryManager.get_sound_bar_value(_game_sound_bar_volume)

func add_sound_to_bar(sound_volume: float):
	var boost = sound_volume / sound_bar_max_volume
	_target_value += boost
	_has_reach_target_value = false
	_check_if_last_lock_pass()

func reset():
	_target_value = 0.0
	_game_sound_bar_volume = 0.0
	_lock_sound_bar = false
	_current_lock_area = 0
	
	sound_bar_animation.self_modulate = Color(1.0, 1.0, 1.0, 1.0)

func _get_last_lock_area_passed() -> float:
	var lock_area_part: float = float(sound_bar_max_volume) / float(number_of_lock_area)
	return floor((_target_value * sound_bar_max_volume) / lock_area_part) * lock_area_part

func _check_if_last_lock_pass():
	var lock_area_part: float = float(sound_bar_max_volume) / float(number_of_lock_area)
	var new_lock_area: int = floor((_target_value * sound_bar_max_volume) / lock_area_part)
	
	if _current_lock_area < new_lock_area:
		_current_lock_area = new_lock_area
		lock_area_pass.emit(new_lock_area)

func change_sound_bar_color(color: Color):
	sound_bar_animation.self_modulate = color
