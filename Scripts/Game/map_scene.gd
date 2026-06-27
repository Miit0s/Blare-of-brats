extends Node3D
class_name MapScene

@onready var base_map: BaseMap = $BaseMap

@export var player_spawn_system: PlayerSpawnSystem
@export var balloon_manager: BalloonManager
@export var item_spawn_system: ItemSpawnSystem

signal new_player_spawn(player: Player)
signal new_item_spawn(new_item: Item)
signal item_will_be_delete(item: Item)
signal balloon_pop(value: float, global_position: Vector3)
signal balloon_pop_by(player_id: int, value: float)
signal wolf_has_hit_player
signal wolf_cutscene_finish

func _enter_tree() -> void:
	balloon_manager.sound_emit.connect(_on_balloon_manager_sound_emit)
	balloon_manager.sound_emit_by.connect(balloon_pop_by.emit)
	item_spawn_system.new_item_spawn.connect(_on_item_spawn_system_new_item_spawn)
	item_spawn_system.item_will_be_delete.connect(_on_item_spawn_system_item_will_be_delete)

func _ready() -> void:
	base_map.wolf_has_hit_player.connect(wolf_has_hit_player.emit)
	base_map.cutscene_finish.connect(wolf_cutscene_finish.emit)

func _on_item_spawn_system_item_will_be_delete(item: Item) -> void:
	item_will_be_delete.emit(item)


func _on_item_spawn_system_new_item_spawn(new_item: Item) -> void:
	new_item_spawn.emit(new_item)


func _on_player_spawn_system_new_player_spawn(player: Player) -> void:
	new_player_spawn.emit(player)


func _on_balloon_manager_sound_emit(value: float, balloon_global_position: Vector3) -> void:
	balloon_pop.emit(value, balloon_global_position)

func activate_danger_phase(activate_cutscene: bool, controller_id_for_vibration: Array[int] = []):
	if activate_cutscene:
		base_map.start_wolf_cutscene(controller_id_for_vibration)
	else:
		base_map.start_simple_cutscene(controller_id_for_vibration)

func activate_wolf_tracking_spot():
	base_map.activate_wolf_light()

func sound_made_at_location(sound_global_position: Vector3):
	base_map.set_new_wolf_eye_target(sound_global_position)
