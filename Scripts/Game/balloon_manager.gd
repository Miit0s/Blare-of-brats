extends Node3D
class_name BalloonManager

@export var balloons: Array[Balloon]

signal sound_emit(value: float)

func _ready() -> void:
	for balloon in balloons:
		balloon.sound_emit.connect(_on_baloon_pop)

func _on_baloon_pop(value: float):
	sound_emit.emit(value)
