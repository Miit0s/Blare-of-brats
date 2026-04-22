extends Node
class_name ItemSpawnSystem

@export_category("Parameters")
@export var nb_item_begin_spawn: int = 4
@export var nb_item_max_spawn: int = 5
@export var minimal_durability: int = 3

@export_category("Spawn")
@export var spawn_points: Array[ItemSpawnPoint]

var _number_of_item_on_scene: int = 0
var _item_that_need_to_spawn: int = 0

signal new_item_spawn(new_item: Item)
signal item_will_be_delete(item: Item)

func _ready() -> void:
	for i in nb_item_begin_spawn:
		_trigger_spawn()

func _item_has_loose_durability(new_durability: int):
	if new_durability == minimal_durability:
		_trigger_spawn()

func _item_destroy(item: Item):
	item.has_loose_durability.disconnect(_item_has_loose_durability)
	item.will_be_destroy.disconnect(_item_destroy)
	
	item_will_be_delete.emit(item)
	
	_number_of_item_on_scene -= 1
	_spawn_item_if_needed(item)

func _trigger_spawn():
	if _number_of_item_on_scene >= nb_item_max_spawn: 
		_item_that_need_to_spawn += 1
		return
	elif _item_that_need_to_spawn > 0:
		_item_that_need_to_spawn -= 1
	
	var item_spawn_position: ItemSpawnPoint = spawn_points.filter(_spawn_point_available).pick_random()
	
	var item_spawned: Item = item_spawn_position.spawn_random_item()
	item_spawned.has_loose_durability.connect(_item_has_loose_durability)
	item_spawned.will_be_destroy.connect(_item_destroy)
	
	new_item_spawn.emit(item_spawned)
	
	_number_of_item_on_scene += 1

func _spawn_item_if_needed(item: Item):
	if item.current_durability > minimal_durability:
		_trigger_spawn()
	elif _item_that_need_to_spawn <= 0:
		return
	else:
		_trigger_spawn()

func _spawn_point_available(spawn_point: ItemSpawnPoint): 
	return not spawn_point.is_item_currently_on_spawn
