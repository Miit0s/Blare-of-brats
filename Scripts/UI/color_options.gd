extends Control
class_name ColorOptions

@export var color_selector: Dictionary[ColorSelector, ShaderMaterial]

var _current_color: ColorSelector = null
var _current_index: int = 0

func _ready() -> void:
	_current_color = color_selector.keys()[0]
	_current_color.selected = true

func select_color(index: int):
	_current_color.selected = false
	_current_color = color_selector.keys()[index]
	_current_index = index
	_current_color.selected = true

func get_current_color_skin() -> ShaderMaterial:
	return color_selector[_current_color]

func get_and_select_next_color() -> ShaderMaterial:
	if _current_index >= color_selector.keys().size() - 1:
		return null
	
	select_color(_current_index + 1)
	return get_current_color_skin()

func get_and_select_previous_color() -> ShaderMaterial:
	if _current_index <= 0:
		return null
	
	select_color(_current_index - 1)
	return get_current_color_skin()
