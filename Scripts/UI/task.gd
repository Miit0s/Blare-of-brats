extends Control
class_name Task

@onready var check: TextureRect = $HBoxContainer/CheckBox/Check

@export var task_text: Label

var is_task_complete: bool = false

signal task_marked_as_complete

func _ready() -> void:
	task_incomplete()

func task_complete():
	if is_task_complete: return
	
	is_task_complete = true
	check.show()
	
	task_marked_as_complete.emit()

func task_incomplete():
	is_task_complete = false
	check.hide()
