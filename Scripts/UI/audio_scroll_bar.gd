@tool
extends HBoxContainer
class_name AudioScrollBar

@onready var label: Label = $Label
@onready var h_slider: HSlider = $HSlider
@onready var volume: Label = $Volume

signal drag_ended(value_changed: bool)
signal value_changed(value: float)

@export_multiline var text = "Text":
	set(new_value):
		text = new_value
		if label:
			label.text = text

@export var range_value: float = 100.0:
	set(new_value):
		range_value = new_value
		h_slider.value = new_value

func _ready() -> void:
	label.text = text


func _on_h_slider_value_changed(value: float) -> void:
	volume.text = str(int(value))
	value_changed.emit(value)


func _on_h_slider_drag_ended(new_value: bool) -> void:
	drag_ended.emit(new_value)

func change_slider_value(value: float):
	h_slider.value = value
