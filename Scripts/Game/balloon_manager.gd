@tool
extends Node3D
class_name BalloonManager

@export var balloons: Array[Balloon]
@export_tool_button("Set Balloons Into Balloons List") var action = _set_all_child_balloons_into_balloon_list

signal sound_emit(value: float)

func _ready() -> void:
	for balloon in balloons:
		balloon.sound_emit.connect(_on_baloon_pop)

func _on_baloon_pop(value: float):
	sound_emit.emit(value)

func _set_all_child_balloons_into_balloon_list():
	balloons.clear()
	for node in get_children():
		balloons.append(node)
