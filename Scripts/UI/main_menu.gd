extends Control

@onready var quit_prompt: Control = $QuitPrompt
@onready var credits: Control = $Credits
@onready var options: Control = $Options

@export var game_start_scene: PackedScene


func _on_play_pressed() -> void:
	get_tree().change_scene_to_packed(game_start_scene)


func _on_options_pressed() -> void:
	options.show()


func _on_credits_pressed() -> void:
	credits.show()


func _on_exit_pressed() -> void:
	quit_prompt.show()
