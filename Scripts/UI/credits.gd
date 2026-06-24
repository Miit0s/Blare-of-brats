extends Control
class_name CreditsUI

@onready var close: Button = $CreditsPanel/VBoxContainer/Close

var on_button_click: WwiseEvent

func _on_close_pressed() -> void:
	hide()
	on_button_click.post(self)


func _on_visibility_changed() -> void:
	if visible:
		close.grab_focus()
