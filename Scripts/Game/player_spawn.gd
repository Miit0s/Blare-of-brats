extends Marker3D
class_name PlayerSpawn

@export var player_prefab: PackedScene

func spawn_player(node_to_add_player: Node3D, player_id: int) -> Player:
	var player: Player = player_prefab.instantiate()
	player.position = position
	player.player_id = player_id
	
	node_to_add_player.add_child.call_deferred(player)
	
	return player
