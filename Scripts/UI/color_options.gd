extends Control
class_name ColorOptions

@export var color_selector: Dictionary[ColorSelector, CharacterColorResource]

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

func get_current_color_skin() -> CharacterColorResource:
	return color_selector[_current_color]

func get_and_select_next_color() -> CharacterColorResource:
	if _current_index >= color_selector.keys().size() - 1:
		return null
	
	var next_index: int = _current_index + 1
	if color_selector.keys()[next_index].is_lock:
		next_index = _get_next_index_not_locked(false)
		if next_index == -1: return null
	
	select_color(next_index)
	return get_current_color_skin()

func get_and_select_previous_color() -> CharacterColorResource:
	if _current_index <= 0:
		return null
	
	var next_index: int = _current_index - 1
	if color_selector.keys()[next_index].is_lock:
		next_index = _get_next_index_not_locked(true)
		if next_index == -1: return null
	
	select_color(next_index)
	return get_current_color_skin()

func lock_color(color: CharacterColorResource):
	var ui_color_selector: ColorSelector = color_selector.find_key(color)
	
	if ui_color_selector:
		ui_color_selector.is_lock = true

func unlock_color(color: CharacterColorResource):
	var ui_color_selector: ColorSelector = color_selector.find_key(color)
	
	if ui_color_selector:
		ui_color_selector.is_lock = false
	
	if get_current_color_skin() == color:
		ui_color_selector.selected = true

## Return -1 if there is no next unlock color for the given steps
func _get_next_index_not_locked(reverse: bool) -> int:
	var index: int = _current_index
	var remaining_next_color: int = _current_index if reverse else (color_selector.keys().size() - 1) - _current_index
	
	for i in remaining_next_color:
		index = index - 1 if reverse else index + 1
		if not color_selector.keys()[index].is_lock:
			return index
	
	return -1
