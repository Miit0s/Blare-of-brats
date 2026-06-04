extends Node3D
class_name MapScene

@export var player_spawn_system: PlayerSpawnSystem
@export var balloon_manager: BalloonManager

signal new_player_spawn(player: Player)
signal new_item_spawn(new_item: Item)
signal item_will_be_delete(item: Item)
signal balloon_pop(value: float)

func _ready() -> void:
	balloon_manager.sound_emit.connect(_on_balloon_manager_sound_emit)

func _on_item_spawn_system_item_will_be_delete(item: Item) -> void:
	item_will_be_delete.emit(item)


func _on_item_spawn_system_new_item_spawn(new_item: Item) -> void:
	new_item_spawn.emit(new_item)


func _on_player_spawn_system_new_player_spawn(player: Player) -> void:
	new_player_spawn.emit(player)


func _on_balloon_manager_sound_emit(value: float) -> void:
	balloon_pop.emit(value)
