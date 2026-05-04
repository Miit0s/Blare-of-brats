extends Node

const OPTION_SAVE_PATH := "user://options_save.tres"

var saved_options: OptionsResource

var _did_options_has_been_apply: bool = false

func _ready() -> void:
	if ResourceLoader.exists(OPTION_SAVE_PATH):
		saved_options = ResourceLoader.load(OPTION_SAVE_PATH)
	else:
		_setup_first_game_load()

func _setup_first_game_load():
	saved_options = OptionsResource.new()

func did_options_has_been_apply() -> bool:
	return _did_options_has_been_apply

func options_has_been_apply():
	_did_options_has_been_apply = true

func save_options():
	var error: Error = ResourceSaver.save(saved_options, OPTION_SAVE_PATH)
	if error != OK:
		push_error("Failed to save settings choose : " + error_string(error))
