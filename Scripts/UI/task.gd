extends Control
class_name Task

@onready var check: TextureRect = $CheckBox/Check

@export var task_text: RichTextLabel
@export var on_completed_sound: WwiseEvent

var is_task_complete: bool = false

signal task_marked_as_complete

func _ready() -> void:
	task_incomplete()

func task_complete():
	if is_task_complete: return
	
	is_task_complete = true
	check.show()
	on_completed_sound.post(self)
	
	task_marked_as_complete.emit()

func task_incomplete():
	is_task_complete = false
	check.hide()
