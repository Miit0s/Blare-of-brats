extends Node3D

@export_category("Instance")
@export var shared_life_bar: SharedLifeBar
@export var game_sound_bar: GameSoundBar

@export_category("GameScene")
@export var game_ended_scene_uid: String

@export_category("Sound")
@export var music_fight: WwiseEvent
@export var lead: WwiseRTPC
@export var round_state: WwiseState

func _ready() -> void: 
	music_fight.post(self)
	round_state.set_value()


func party_finish(dead_player_id: int):
	print("Player with ID : " + str(dead_player_id) + " loose the game")
	get_tree().change_scene_to_file(game_ended_scene_uid)


func _on_shared_life_bar_player_dead(dead_player_id: int) -> void:
	print("No more health trigger")
	party_finish(dead_player_id)


func _on_game_sound_bar_sound_bar_fill() -> void:
	print("Sound bar fill trigger")
	party_finish(shared_life_bar.get_player_id_with_least_health())


func lifebar_value_change(lifebar_value: float):
	lead.set_value(self, lifebar_value * 100)


func _on_item_spawn_system_new_item_spawn(new_item: Item) -> void:
	new_item.sound_made.connect(game_sound_bar.add_sound_to_bar)


func _on_item_spawn_system_item_will_be_delete(item: Item) -> void:
	item.sound_made.disconnect(game_sound_bar.add_sound_to_bar)
