extends Node3D
class_name Balloon

@onready var area_3d: Area3D = $Area3D
@onready var animated_sprite_3d: AnimatedSprite3D = $AnimatedSprite3D

@export var sound_on_pop: float = 5
@export var damage_on_pop: float = 0.5

@export var speed_range_minimum: float = 0.8
@export var speed_range_max: float = 1.2

@export var pop_sound: WwiseEvent

var _already_pop: bool = false

signal sound_emit(value: float, global_position: Vector3)

func _ready() -> void:
	area_3d.body_entered.connect(_on_body_area_entered)
	
	animated_sprite_3d.play("default", randf_range(speed_range_minimum, speed_range_max))

func _on_body_area_entered(body: Node3D):
	if _already_pop: return
	_already_pop = true
	
	if body is Player:
		body.hit(damage_on_pop, Vector3.ZERO, false)
	
	sound_emit.emit(sound_on_pop, global_position)
	
	animated_sprite_3d.play("pop", 1.0)
	pop_sound.post(self)
	
	await animated_sprite_3d.animation_finished
	queue_free()
