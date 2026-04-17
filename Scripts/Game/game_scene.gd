extends Node3D

@onready var shared_life_bar: SharedLifeBar = $CanvasLayer/SharedLifeBar

@export var game_ended_scene_uid: String

func party_finish(dead_player_id: int):
	print("Player with ID : " + str(dead_player_id) + " loose the game")
	get_tree().change_scene_to_file(game_ended_scene_uid)

func _on_shared_life_bar_player_dead(dead_player_id: int) -> void:
	print("No more health trigger")
	party_finish(dead_player_id)


func _on_game_sound_bar_sound_bar_fill() -> void:
	print("Sound bar fill trigger")
	party_finish(shared_life_bar.get_player_id_with_least_health())
