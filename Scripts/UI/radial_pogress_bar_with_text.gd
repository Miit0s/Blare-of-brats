@tool
extends HBoxContainer
class_name RadialProgressBarWithText

@onready var radial_progress_bar: ColorRect = $RadialProgressBar
@onready var label: Label = $Label

@export var hold_duration: float

@export_multiline var text = "Text":
	set(new_value):
		text = new_value
		if label:
			label.text = text

var _player_his_holding_key: bool = false
var _hold_time: float = 0
var _progress_finish: bool = false

signal hold_finish

func _ready() -> void:
	label.text = text

func _process(delta: float) -> void:
	if _player_his_holding_key and not _progress_finish:
		_hold_time = move_toward(_hold_time, 1.0, delta / hold_duration)

		if _hold_time >= 1:
			_progress_finish = true 
	elif not _progress_finish:
		_hold_time = move_toward(_hold_time, 0.0, delta / hold_duration)
	
	radial_progress_bar.material.set_shader_parameter("progress", _hold_time)

func player_start_holding_key():
	_player_his_holding_key = true

func player_stop_holding_key():
	_player_his_holding_key = false
