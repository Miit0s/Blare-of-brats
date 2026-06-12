extends Control
class_name TaskList

@onready var task_container: VBoxContainer = $TaskContainer
@onready var texture_rect: TextureRect = $TextureRect

@export var task_prefab: PackedScene

var _task_completed: int = 0
var _task_to_complete: int = 0

signal all_task_complete

func _ready() -> void:
	clear_task()

func setup_color_for_task_list(color: CharacterColorResource):
	texture_rect.self_modulate = color.main_color

func add_new_task(task_node: Task):
	task_node.task_marked_as_complete.connect(one_current_task_complete)
	task_node.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	task_container.add_child(task_node)
	_task_to_complete += 1

func clear_task():
	_task_completed = 0
	_task_to_complete = 0
	for child in task_container.get_children():
		child.queue_free()

func one_current_task_complete():
	_task_completed += 1
	
	if _task_completed >= _task_to_complete: all_task_complete.emit()
