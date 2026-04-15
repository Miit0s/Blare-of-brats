extends Control


func _on_yes_pressed() -> void:
	get_tree().quit()


func _on_no_pressed() -> void:
	hide()
