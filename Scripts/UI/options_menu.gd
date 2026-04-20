extends Control

@onready var game: GameMenu = $Control/VBoxContainer/TabContainer/Game
@onready var audio: AudioMenu = $Control/VBoxContainer/TabContainer/Audio
@onready var video: VideoMenu = $Control/VBoxContainer/TabContainer/Video



func _ready() -> void:
	if not GameOptions.did_options_has_been_apply():
		apply_options_to_menu()
		GameOptions.options_has_been_apply()


func apply_options_to_menu():
	game.apply_options(GameOptions.saved_options)
	audio.apply_options(GameOptions.saved_options)
	video.apply_options(GameOptions.saved_options)


func _on_game_desactivate_onboarding_value_changed(is_on_boarding_activate: bool) -> void:
	GameOptions.saved_options.desactivate_on_boarding = !is_on_boarding_activate
	GameOptions.save_options()


func _on_game_player_marker_value_changed(is_marker_activate: bool) -> void:
	GameOptions.saved_options.activate_player_marker = is_marker_activate
	GameOptions.save_options()


func _on_audio_ambiance_value_changed(value: float) -> void:
	GameOptions.saved_options.ambiance_volume = value
	GameOptions.save_options()


func _on_audio_general_value_changed(value: float) -> void:
	GameOptions.saved_options.general_volume = value
	GameOptions.save_options()


func _on_audio_music_value_changed(value: float) -> void:
	GameOptions.saved_options.music_volume = value
	GameOptions.save_options()


func _on_audio_sound_design_value_changed(value: float) -> void:
	GameOptions.saved_options.sound_design_volume = value
	GameOptions.save_options()


func _on_video_camera_shake_change(is_camera_shake_activate: bool) -> void:
	GameOptions.saved_options.activate_camera_shake = is_camera_shake_activate
	GameOptions.save_options()


func _on_video_fullscreen_change(fullscreen: bool) -> void:
	GameOptions.saved_options.fullscreen = fullscreen
	GameOptions.save_options()


func _on_video_hud_toggle_change(is_hud_activate: bool) -> void:
	GameOptions.saved_options.desactivate_hud = !is_hud_activate
	GameOptions.save_options()


func _on_video_resolution_change(resolution: Vector2i) -> void:
	GameOptions.saved_options.resolution = resolution
	GameOptions.save_options()


func _on_video_v_sync_change(is_vsync_activate: bool) -> void:
	GameOptions.saved_options.activate_v_sync = is_vsync_activate
	GameOptions.save_options()


func _on_close_pressed() -> void:
	hide()
