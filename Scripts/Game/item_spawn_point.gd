extends Node3D
class_name ItemSpawnPoint

@onready var spawn_particle: GPUParticles3D = $SpawnParticle

@export var possible_items: Array[PackedScene]
@export var spawn_delay: float = 1

var is_item_currently_on_spawn: bool

var _overlapping_count: int = 0
var _will_spawn: bool = false

func spawn_random_item() -> Item:
	if possible_items.is_empty(): return
	
	var item: Item = possible_items.pick_random().instantiate()
	spawn(item)
	
	return item

func spawn(item: Item):
	is_item_currently_on_spawn = true
	_will_spawn = true
	
	spawn_particle.emitting = true
	await get_tree().create_timer(spawn_delay).timeout
	
	add_child(item)
	_will_spawn = false


func _on_item_detector_body_entered(_body: Node3D) -> void:
	_overlapping_count += 1
	is_item_currently_on_spawn = true


func _on_item_detector_body_exited(_body: Node3D) -> void:
	_overlapping_count -= 1
	
	if _overlapping_count <= 0 and not _will_spawn:
		_overlapping_count = 0
		is_item_currently_on_spawn = false
