@tool
extends HBoxContainer
class_name ToggleButtonWithName

@onready var label: Label = $Label
@onready var check_button: CheckButton = $CheckButton

@export_multiline var text: String = "Text":
	set(new_value):
		text = new_value
		if label:
			label.text = new_value

signal button_toggled(toggled_on: bool)

func _ready() -> void:
	label.text = text

func _on_check_button_toggled(toggled_on: bool) -> void:
	button_toggled.emit(toggled_on)

func set_toggle_button(value: bool):
	check_button.button_pressed = value
