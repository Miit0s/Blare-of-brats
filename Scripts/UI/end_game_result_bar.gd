@tool
extends Control
class_name EndGameResultBar

@export var rich_text_label: RichTextLabel
@export var texture_rect: TextureRect

@export var text: String = "Text":
	set(new_value):
		text = new_value
		rich_text_label.text = text
@export_range(0, 1, 0.01) var progress: float = 0.5:
	set(new_value):
		progress = new_value
		_set_new_progress_value(progress)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rich_text_label.text = text
	_set_new_progress_value(progress)

func _set_new_progress_value(value: float):
	var shader_material: ShaderMaterial = texture_rect.material
	shader_material.set_shader_parameter("progress", value)
