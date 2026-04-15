extends Control

const OPTION_SAVE_PATH := "user://options_save.tres"

@onready var game: GameMenu = $Control/VBoxContainer/TabContainer/Game
@onready var audio: AudioMenu = $Control/VBoxContainer/TabContainer/Audio
@onready var video: VideoMenu = $Control/VBoxContainer/TabContainer/Video

var saved_options: OptionsResource

func _ready() -> void:
	if ResourceLoader.exists(OPTION_SAVE_PATH):
		saved_options = ResourceLoader.load(OPTION_SAVE_PATH)
		apply_options_to_menu()
	else:
		_setup_first_game_load()

func _setup_first_game_load():
	saved_options = OptionsResource.new()
	
	apply_options_to_menu()

func apply_options_to_menu():
	game.apply_options(saved_options)
	audio.apply_options(saved_options)
	video.apply_options(saved_options)

func save_options():
	var error: Error = ResourceSaver.save(saved_options, OPTION_SAVE_PATH)
	if error != OK:
		push_error("Failed to save settings choose : " + error_string(error))


func _on_game_desactivate_onboarding_value_changed(is_on_boarding_activate: bool) -> void:
	saved_options.desactivate_on_boarding = !is_on_boarding_activate
	save_options()


func _on_game_player_marker_value_changed(is_marker_activate: bool) -> void:
	saved_options.activate_player_marker = is_marker_activate
	save_options()


func _on_audio_ambiance_value_changed(value: float) -> void:
	saved_options.ambiance_volume = value
	save_options()


func _on_audio_general_value_changed(value: float) -> void:
	saved_options.general_volume = value
	save_options()


func _on_audio_music_value_changed(value: float) -> void:
	saved_options.music_volume = value
	save_options()


func _on_audio_sound_design_value_changed(value: float) -> void:
	saved_options.sound_design_volume = value
	save_options()


func _on_video_camera_shake_change(is_camera_shake_activate: bool) -> void:
	saved_options.activate_camera_shake = is_camera_shake_activate
	save_options()


func _on_video_fullscreen_change(fullscreen: bool) -> void:
	saved_options.fullscreen = fullscreen
	save_options()


func _on_video_hud_toggle_change(is_hud_activate: bool) -> void:
	saved_options.desactivate_hud = !is_hud_activate
	save_options()


func _on_video_resolution_change(resolution: Vector2i) -> void:
	saved_options.resolution = resolution
	save_options()


func _on_video_v_sync_change(is_vsync_activate: bool) -> void:
	saved_options.activate_v_sync = is_vsync_activate
	save_options()


func _on_close_pressed() -> void:
	hide()
