extends Control
class_name QuitPromptUI

@onready var yes: Button = $ChoosePanel/VBoxContainer/HBoxContainer/Yes
@onready var no: Button = $ChoosePanel/VBoxContainer/HBoxContainer/No

var on_button_focus: WwiseEvent
var on_button_click: WwiseEvent

func _ready() -> void:
	yes.focus_entered.connect(_trigger_focus_sound)
	no.focus_entered.connect(_trigger_focus_sound)

func _on_yes_pressed() -> void:
	get_tree().quit()


func _on_no_pressed() -> void:
	on_button_click.post(self)
	hide()


func _on_visibility_changed() -> void:
	if visible:
		no.grab_focus()

func _trigger_focus_sound():
	on_button_focus.post(self)
