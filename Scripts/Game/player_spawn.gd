extends Marker3D
class_name PlayerSpawn

@export var player_prefabs: Dictionary[ControllerSlot.PossibleSkin, PackedScene]

func spawn_player(node_to_add_player: Node3D, player_data: PlayerCharacterSelection) -> Player:
	var player: Player = player_prefabs[player_data.skin].instantiate()
	player.position = position
	player.player_id = player_data.player_id
	player.apply_skin_and_color(player_data)
	
	node_to_add_player.add_child.call_deferred(player)
	
	return player
