extends Control
class_name TaskList

@onready var task_container: VBoxContainer = $TaskContainer
@onready var texture_rect: TextureRect = $TextureRect

@export var is_reverse: bool = false
@export var task_prefab: PackedScene

@export_category("Tween")
@export var spawn_tween_duration: float = 0.3
@export var task_spawn_duration: float = 0.8

var _task_completed: int = 0
var _task_to_complete: int = 0

signal all_task_complete

signal spawn_anim_finish
signal despawn_anim_not_finish

func _ready() -> void:
	clear_task()

func setup_color_for_task_list(color: CharacterColorResource):
	texture_rect.self_modulate = color.main_color

func add_new_task(task_node: Task, task_info: TaskInfo, player_id: int):
	task_node.task_marked_as_complete.connect(one_current_task_complete)
	task_node.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	task_node.hide()
	
	var copy_task_info: TaskInfo = task_info.duplicate()
	copy_task_info.action_input = "{" + task_info.action_input + "_" + str(player_id) + "}"
	task_node.fill_task_with_info(copy_task_info)
	
	task_container.add_child(task_node)
	_task_to_complete += 1
	
	var final_position: Vector2 = task_node.position
	task_node.position = task_node.position + Vector2(size.x, 0) if is_reverse else task_node.position - Vector2(size.x, 0)
	
	var task_spawn_tween: Tween = create_tween()
	task_spawn_tween.set_ease(Tween.EASE_OUT)
	task_spawn_tween.set_trans(Tween.TRANS_BACK)
	task_spawn_tween.tween_property(task_node, "visible", true, 0)
	task_spawn_tween.tween_property(task_node, "position", final_position, task_spawn_duration)
	
	#TODO: Fix this tween

func clear_task():
	_task_completed = 0
	_task_to_complete = 0
	for child in task_container.get_children():
		child.queue_free()

func one_current_task_complete():
	_task_completed += 1
	
	if _task_completed >= _task_to_complete: all_task_complete.emit()

func trigger_spawn_animation():
	var final_position: Vector2 = position
	var begin_position: Vector2 = position + Vector2(size.x, 0) if is_reverse else position - Vector2(size.x, 0)
	set_position(begin_position)
	
	var spawn_tween: Tween = create_tween()
	spawn_tween.set_ease(Tween.EASE_OUT)
	spawn_tween.set_trans(Tween.TRANS_QUART)
	spawn_tween.tween_property(self, "visible", true, 0)
	spawn_tween.tween_property(self, "position", final_position, spawn_tween_duration)
	spawn_tween.finished.connect(spawn_anim_finish.emit)

func trigger_despawn_animation():
	var final_position: Vector2 = position - Vector2(size.x, 0) if is_reverse else position + Vector2(size.x, 0)
	
	var despawn_tween: Tween = create_tween()
	despawn_tween.set_ease(Tween.EASE_IN)
	despawn_tween.set_trans(Tween.TRANS_QUART)
	despawn_tween.tween_property(self, "position", final_position, spawn_tween_duration)
	despawn_tween.tween_property(self, "visible", false, 0)
	despawn_tween.finished.connect(despawn_anim_not_finish.emit)
