extends Control

@onready var no: Button = $ChoosePanel/VBoxContainer/HBoxContainer/No

func _on_yes_pressed() -> void:
	get_tree().quit()


func _on_no_pressed() -> void:
	hide()


func _on_visibility_changed() -> void:
	if visible:
		no.grab_focus()
