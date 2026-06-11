@tool
extends Node3D
class_name BalloonManager

@export var balloons: Array[Balloon]
@export_tool_button("Set Balloons Into Balloons List") var action = _set_all_child_balloons_into_balloon_list

signal sound_emit(value: float, global_position: Vector3)

func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	for balloon in balloons:
		balloon.sound_emit.connect(_on_baloon_pop)

func _on_baloon_pop(value: float, balloon_global_position: Vector3):
	sound_emit.emit(value, balloon_global_position)

func _set_all_child_balloons_into_balloon_list():
	balloons.clear()
	for node in get_children():
		balloons.append(node)
