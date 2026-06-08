extends Control
class_name Task

@onready var task_text: Label = $HBoxContainer/TaskText

@onready var cross: TextureRect = $HBoxContainer/Cross
@onready var check: TextureRect = $HBoxContainer/Check

var is_task_complete: bool = false

signal task_marked_as_complete

func _ready() -> void:
	task_incomplete()

func task_complete():
	is_task_complete = true
	cross.hide()
	check.show()

func task_incomplete():
	is_task_complete = false
	check.hide()
	check.show()
