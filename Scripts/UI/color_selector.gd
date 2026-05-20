@tool
extends ColorRect
class_name ColorSelector

@export var color_in: Color = Color.WHITE:
	set(new_value):
		color_in = new_value
		inside_color.color = color_in
		_update_color()
@export var color_out: Color = Color.BLACK:
	set(new_value):
		color_out = new_value
		color = color_out
@export var selected: bool = false:
	set(new_value):
		selected = new_value
		_update_color()

@export var inside_color: ColorRect

func _ready() -> void:
	inside_color.color = color_in
	color = color_out
	_update_color()

func _update_color():
	color = color_out if selected else color_in
