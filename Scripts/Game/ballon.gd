extends Node3D
class_name Balloon

@onready var area_3d: Area3D = $Area3D
@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D
@onready var sprite_3d: Sprite3D = $Sprite3D

@export var sound_on_pop: float = 5

var _already_pop: bool = false

signal sound_emit(value: float)

func _ready() -> void:
	area_3d.body_entered.connect(_on_body_area_entered)

func _on_body_area_entered(_body: Node3D):
	if _already_pop: return
	
	_already_pop = true
	sprite_3d.hide()
	sound_emit.emit(sound_on_pop)
	
	gpu_particles_3d.restart()
	await gpu_particles_3d.finished
	queue_free()
