@tool
extends Control
class_name ColorSelector

@export var selected: bool = false:
	set(new_value):
		selected = new_value
		_update_selection()
@export var color_in: Color = Color.WHITE:
	set(new_value):
		color_in = new_value
		inside_color.self_modulate = color_in

@export_category("Setup Value")
@export var background: TextureRect
@export var inside_color: TextureRect
@export var background_begin_size: Vector2
@export var inside_color_begin_size: Vector2

func _ready() -> void:
	inside_color.self_modulate = color_in
	_update_selection()

func _update_selection():
	if selected: 
		background.size = size
		inside_color.size = inside_color_begin_size
		_center_node(background)
		_center_node(inside_color)
	else: 
		background.size = background_begin_size
		inside_color.size = background_begin_size
		_center_node(background)
		_center_node(inside_color)

func _center_node(node: Control):
	node.position = (size - node.size) / 2
