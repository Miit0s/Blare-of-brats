extends Node3D
class_name PlayerSpawnSystem

@export var possible_player_id: Array[int] = [0,1]
@export var players_spawn: Array[PlayerSpawn]
@export var player_parent_node: Node

func _ready() -> void:
	var possible_player_id_copy: Array[int] = possible_player_id.duplicate()
	
	for player_spawn in players_spawn:
		player_spawn.spawn_player(
			player_parent_node, 
			possible_player_id_copy.pop_at(randi_range(0, possible_player_id_copy.size() - 1))
		)
