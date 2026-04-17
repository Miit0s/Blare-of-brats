extends Control

@onready var play_button: Button = $MainButton/Play
@onready var options_button: Button = $MainButton/Options
@onready var credits_button: Button = $MainButton/Credits
@onready var exit_button: Button = $MainButton/Exit

@onready var quit_prompt: Control = $QuitPrompt
@onready var credits: Control = $Credits
@onready var options: Control = $Options

@export var game_start_scene_uid: String

func _ready() -> void:
	play_button.grab_focus()

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(game_start_scene_uid)


func _on_options_pressed() -> void:
	options.show()


func _on_credits_pressed() -> void:
	credits.show()


func _on_exit_pressed() -> void:
	quit_prompt.show()


func _on_quit_prompt_visibility_changed() -> void:
	if not quit_prompt.visible:
		exit_button.grab_focus()


func _on_credits_visibility_changed() -> void:
	if not credits.visible:
		credits_button.grab_focus()
