extends Control
class_name AudioMenu

@onready var general: AudioScrollBar = $Control/VBoxContainer/General
@onready var music: AudioScrollBar = $Control/VBoxContainer/Music
@onready var sound_design: AudioScrollBar = $Control/VBoxContainer/SoundDesign
@onready var ambiance: AudioScrollBar = $Control/VBoxContainer/Ambiance

signal general_value_changed(value: float)
signal music_value_changed(value: float)
signal sound_design_value_changed(value: float)
signal ambiance_value_changed(value: float)

#The volume bar go from 0 to 100

func _on_general_value_changed(value: float) -> void:
	general_value_changed.emit(value)


func _on_music_value_changed(value: float) -> void:
	music_value_changed.emit(value)


func _on_sound_design_value_changed(value: float) -> void:
	sound_design_value_changed.emit(value)


func _on_ambiance_value_changed(value: float) -> void:
	ambiance_value_changed.emit(value)

func apply_options(option_ressource: OptionsResource):
	general.change_slider_value(option_ressource.general_volume)
	music.change_slider_value(option_ressource.music_volume)
	sound_design.change_slider_value(option_ressource.sound_design_volume)
	ambiance.change_slider_value(option_ressource.ambiance_volume)
