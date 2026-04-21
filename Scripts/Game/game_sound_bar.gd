extends Control
class_name GameSoundBar

@onready var sound_bar: ColorRect = $SoundBar

@export var sound_bar_max_volume = 100

@export_category("Tween Value")
@export var shader_value_change_speed: float = 0.3

var _game_sound_bar_volume: float = 0:
	set(new_value):
			var clamped_value: float = minf(1.0, maxf(0, new_value))
			_game_sound_bar_volume = clamped_value
			sound_bar.material.set_shader_parameter("progress", clamped_value)

signal sound_bar_fill()

func add_sound_to_bar(sound_volume: float):
	var final_sound_volume: float = (sound_volume / sound_bar_max_volume) + _game_sound_bar_volume
	
	var tween: Tween = create_tween()
	tween.tween_property(
		self,
		"_game_sound_bar_volume",
		final_sound_volume,
		shader_value_change_speed
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	await tween.finished
	
	if _game_sound_bar_volume >= 1.0: sound_bar_fill.emit()
