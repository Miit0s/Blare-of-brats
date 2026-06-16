@tool
extends Control
class_name ColorSelector

@onready var lock_effect: ColorRect = $InsideColor/LockEffect

@export var selected: bool = false:
	set(new_value):
		selected = new_value
		_update_selection()
@export var is_lock: bool = false:
	set(new_value):
		is_lock = new_value
		_update_lock()
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

func _update_lock():
	if is_lock:
		selected = false
		lock_effect.show()
	else: 
		lock_effect.hide()
