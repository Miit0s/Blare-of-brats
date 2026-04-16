extends Control

@onready var close: Button = $CreditsPanel/VBoxContainer/Close

func _on_close_pressed() -> void:
	hide()


func _on_visibility_changed() -> void:
	if visible:
		close.grab_focus()
