extends Node3D
class_name PlayerSpawnSystem

@export var players_spawn: Array[PlayerSpawn]
@export var player_parent_node: Node

signal new_player_spawn(player: Player)

func spawn_players(players_data: Array[PlayerCharacterSelection]):
	var index: int = 0
	
	for player_spawn in players_spawn:
		var new_player = player_spawn.spawn_player(
			player_parent_node, 
			players_data[index]
		)
		new_player_spawn.emit(new_player)
		
		index += 1
