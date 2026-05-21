extends Control
class_name GameSoundBar

@onready var sound_bar: TextureRect = $SoundBar

@export var sound_bar_max_volume = 100
@export var timer_sync_speed: float = 0.005

@export_category("Tween Value")
@export var shader_value_change_speed: float = 0.3

var _game_sound_bar_volume: float = 0:
	set(new_value):
		_game_sound_bar_volume = clampf(new_value, 0.0, 1.0)
		sound_bar.material.set_shader_parameter("value", _game_sound_bar_volume)

var _timer_duration: int = 0
var _target_value_by_time: float = 0
var _timer_running: bool = false

signal sound_bar_fill

func _process(delta: float) -> void:
	if not _timer_running: return
	
	if _game_sound_bar_volume >= 1.0: 
		_timer_running = false
		sound_bar_fill.emit()
	
	_target_value_by_time += delta / _timer_duration
	
	if _game_sound_bar_volume > _target_value_by_time:
		_game_sound_bar_volume = move_toward(_game_sound_bar_volume, _target_value_by_time, timer_sync_speed * delta)
	else:
		_game_sound_bar_volume = _target_value_by_time

func add_sound_to_bar(sound_volume: float):
	var boost = sound_volume / sound_bar_max_volume
	_game_sound_bar_volume += boost

func reset():
	_timer_running = false
	_game_sound_bar_volume = 0.0
	_target_value_by_time = 0.0
	_timer_duration = 0

func start_timer(duration: int):
	_timer_duration = duration
	_target_value_by_time = 0.0
	_game_sound_bar_volume = 0.0
	_timer_running = true
