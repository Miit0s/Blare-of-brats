extends Control
class_name TaskList

@onready var task_container: VBoxContainer = $TaskContainer
@onready var texture_rect: TextureRect = $TextureRect

@export var is_reverse: bool = false
@export var task_prefab: PackedScene

@export_category("Tween")
@export var spawn_tween_duration: float = 0.3
@export var task_spawn_duration: float = 0.6
@export var wait_time_before_new_task_anim: float = 0.15

var _task_completed: int = 0
var _task_to_complete: int = 0

var _spawn_anim_queue: Array[Task]
var _remove_anim_queue: Array[Task]
var _task_to_free: Array[Task]
var _time_passed: float = 0

var _remove_anim_finish: bool = true

signal all_task_complete

signal spawn_anim_finish
signal despawn_anim_finish

signal task_remove_anim_finish

func _ready() -> void:
	clear_task()
	task_remove_anim_finish.connect(_clear_task_to_free)

func _process(delta: float) -> void:
	if _spawn_anim_queue.is_empty() and _remove_anim_queue.is_empty(): return
	
	_time_passed += delta
	
	if _time_passed < wait_time_before_new_task_anim: return
	
	if not _remove_anim_queue.is_empty():
		_remove_anim_finish = false
		
		var task: Task = _remove_anim_queue.pop_front()
		var tween: Tween = _make_remove_animation_for_task(task)
		_task_to_free.append(task)
		_time_passed = 0.0
		
		if _remove_anim_queue.is_empty(): 
			tween.finished.connect(func(): _remove_anim_finish = true, ConnectFlags.CONNECT_ONE_SHOT)
			tween.finished.connect(task_remove_anim_finish.emit, ConnectFlags.CONNECT_ONE_SHOT)
	elif _remove_anim_finish:
		_make_add_animation_for_task(_spawn_anim_queue.pop_front())
		_time_passed = 0.0

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
	
	_spawn_anim_queue.append(task_node)

func clear_task():
	_task_completed = 0
	_task_to_complete = 0
	
	_remove_anim_queue.append_array(task_container.get_children())

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
	var final_position: Vector2 = position + Vector2(size.x, 0) if is_reverse else position - Vector2(size.x, 0)
	
	var despawn_tween: Tween = create_tween()
	despawn_tween.set_ease(Tween.EASE_IN)
	despawn_tween.set_trans(Tween.TRANS_QUART)
	despawn_tween.tween_property(self, "position", final_position, spawn_tween_duration)
	despawn_tween.tween_property(self, "visible", false, 0)
	despawn_tween.finished.connect(despawn_anim_finish.emit)

func _make_add_animation_for_task(task_node: Task) -> Tween:
	task_node.task_container.position = Vector2(size.x, 0) if is_reverse else -Vector2(size.x, 0)
	
	var task_spawn_tween: Tween = create_tween()
	task_spawn_tween.set_ease(Tween.EASE_OUT)
	task_spawn_tween.set_trans(Tween.TRANS_BACK)
	task_spawn_tween.tween_property(task_node, "visible", true, 0)
	task_spawn_tween.tween_property(task_node.task_container, "position", Vector2.ZERO, task_spawn_duration)
	
	return task_spawn_tween

func _make_remove_animation_for_task(task_node: Task) -> Tween:
	var task_final_pos: Vector2 = Vector2(size.x, 0) if is_reverse else -Vector2(size.x, 0)
	
	var task_remove_tween: Tween = create_tween()
	task_remove_tween.set_ease(Tween.EASE_IN)
	task_remove_tween.set_trans(Tween.TRANS_BACK)
	task_remove_tween.tween_property(task_node, "visible", true, 0)
	task_remove_tween.tween_property(task_node.task_container, "position", task_final_pos, task_spawn_duration)
	
	return task_remove_tween

func _clear_task_to_free():
	for i in range(_task_to_free.size() - 1, -1, -1):
		_task_to_free[i].queue_free()
	_task_to_free.clear()
