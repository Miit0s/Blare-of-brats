extends Control
class_name TaskList

@onready var task_container: VBoxContainer = $VBoxContainer/TaskContainer

var _task_completed: int = 0
var _task_to_complete: int = 0

signal all_task_complete

func add_new_task(task_node: Task):
	task_node.task_marked_as_complete.connect(one_current_task_complete)
	task_container.add_child(task_node)

func clear_task():
	for child in task_container.get_children():
		child.queue_free()

func one_current_task_complete():
	_task_to_complete += 1
	
	if _task_to_complete >= _task_completed: all_task_complete.emit()
