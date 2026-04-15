@tool
extends HBoxContainer
class_name DropDownList

@onready var label: Label = $Label
@onready var option_button: OptionButton = $OptionButton

@export_multiline var text: String = "Text":
	set(new_value):
		text = new_value
		if label:
			label.text = new_value

@export var options_list: Array[String]:
	set(new_value):
		options_list = new_value
		if option_button:
			update_options(new_value)

signal item_focused(index: int)
signal item_selected(index: int)

func _ready() -> void:
	label.text = text
	
	update_options(options_list)

func update_options(new_options: Array[String]):
	option_button.clear()
	for option in new_options:
		option_button.add_item(option)

func force_update():
	update_options(options_list)

func _on_option_button_item_focused(index: int) -> void:
	item_focused.emit(index)


func _on_option_button_item_selected(index: int) -> void:
	item_selected.emit(index)

func select_item(idx: int):
	option_button.select(idx)
