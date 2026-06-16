extends Control
class_name Task

@onready var check: TextureRect = $TaskContainer/CheckBox/Check

@export_category("Instance")
@export var task_text: RichTextLabel
@export var controller_icon_parser: ControllerIconParser
@export var task_container: Control

@export_category("Sound")
@export var on_completed_sound: WwiseEvent

@export_category("Tween")
@export var check_tween_duration: float = 0.4
@export var check_tween_rotation: float = 5

var is_task_complete: bool = false

signal task_marked_as_complete

func _ready() -> void:
	task_incomplete()

func task_complete():
	if is_task_complete: return
	
	is_task_complete = true
	
	check.scale = Vector2.ZERO
	check.rotation = check_tween_rotation
	
	var show_checkmark_tween: Tween = create_tween()
	show_checkmark_tween.set_ease(Tween.EASE_IN)
	show_checkmark_tween.set_trans(Tween.TRANS_QUAD)
	show_checkmark_tween.tween_property(check, "visible", true, 0)
	show_checkmark_tween.tween_property(check, "scale", Vector2.ONE, check_tween_duration)
	show_checkmark_tween.set_trans(Tween.TRANS_LINEAR)
	show_checkmark_tween.parallel().tween_property(check, "rotation", 0, check_tween_duration)
	
	on_completed_sound.post(self)
	
	task_marked_as_complete.emit()

func task_incomplete():
	is_task_complete = false
	check.hide()

func fill_task_with_info(info: TaskInfo):
	task_text.text = info.task_text
	controller_icon_parser.raw_text = info.action_input
