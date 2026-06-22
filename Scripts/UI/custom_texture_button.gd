extends Control
class_name CustomTextureButton

@onready var texture_button: TextureButtonFocusReplace = $TextureButton
@onready var label: Label = $Label

@export var tween_duration: float = 0.3
@export var scale_expand: Vector2 = Vector2(1.8, 1.8)

@export var label_base_position: Vector2 = Vector2.ZERO
@export var label_position_on_tween: Vector2 = Vector2.ZERO

@export_category("Theme")
@export var theme_on_focus: Theme
@export var base_theme: Theme

signal pressed

func _ready() -> void:
	texture_button.focus_entered.connect(_on_button_focus_enter)
	texture_button.focus_exited.connect(_on_button_focus_exit)
	texture_button.pressed.connect(pressed.emit)

func _on_button_focus_enter():
	_zoom_in()

func _on_button_focus_exit():
	_zoom_out()

func _zoom_in():
	custom_minimum_size.y = texture_button.size.y * scale_expand.y
	theme = theme_on_focus
	
	var zoom_in: Tween = create_tween()
	zoom_in.set_ease(Tween.EASE_OUT)
	zoom_in.set_trans(Tween.TRANS_BACK)
	zoom_in.tween_property(texture_button, "scale", scale_expand, tween_duration)
	zoom_in.parallel().tween_property(label, "position", label_position_on_tween, tween_duration)

func _zoom_out():
	custom_minimum_size.y = texture_button.size.y
	theme = base_theme
	
	var zoom_in: Tween = create_tween()
	zoom_in.set_ease(Tween.EASE_OUT)
	zoom_in.set_trans(Tween.TRANS_QUINT)
	zoom_in.tween_property(texture_button, "scale", Vector2.ONE, tween_duration)
	zoom_in.parallel().tween_property(label, "position", label_base_position, tween_duration)
