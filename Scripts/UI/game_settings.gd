extends Control
class_name GameMenu

@onready var desactivate_onboarding: ToggleButtonWithName = $Control/VBoxContainer/DesactivateOnboarding
@onready var player_marker: ToggleButtonWithName = $Control/VBoxContainer/PlayerMarker

signal desactivate_onboarding_value_changed(is_on_boarding_activate: bool)
signal player_marker_value_changed(is_marker_activate: bool)

func apply_options(option_ressource: OptionsResource):
	desactivate_onboarding.set_toggle_button(option_ressource.desactivate_on_boarding)
	player_marker.set_toggle_button(option_ressource.activate_player_marker)


func _on_desactivate_onboarding_button_toggled(toggled_on: bool) -> void:
	desactivate_onboarding_value_changed.emit(toggled_on)


func _on_player_marker_button_toggled(toggled_on: bool) -> void:
	player_marker_value_changed.emit(toggled_on)
