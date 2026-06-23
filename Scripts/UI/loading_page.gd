extends CanvasLayer

@onready var loading_page: SubViewportContainer = $LoadingPage

@export var transition_duration: float = 0.5

var is_displaying: bool = false

var _end_value: float = 2.75

var _next_scene_name: String = ""
var _start_transtion_finish: bool = false
var _packed_loaded_event_send: bool = false

signal transition_finish
signal packed_scene_loaded(scene: PackedScene)

func _process(_delta: float) -> void:
	if not _start_transtion_finish: return
	if not is_displaying: return
	
	var scene_load_status = ResourceLoader.load_threaded_get_status(_next_scene_name)
	
	if scene_load_status == ResourceLoader.THREAD_LOAD_LOADED and not _packed_loaded_event_send:
		_packed_loaded_event_send = true
		var new_scene: PackedScene = ResourceLoader.load_threaded_get(_next_scene_name)
		packed_scene_loaded.emit(new_scene)
		_next_scene_name = ""

func start_transtion_to_scene(scene_name: String):
	ResourceLoader.load_threaded_request(scene_name)
	_next_scene_name = scene_name
	
	spawn_transtion()
	
	await get_tree().create_timer(transition_duration).timeout
	_start_transtion_finish = true

func spawn_transtion():
	var start_value: float = 0.0
	var end_value: float = _end_value
	
	var spawn_tween: Tween = create_tween()
	spawn_tween.set_ease(Tween.EASE_IN)
	spawn_tween.set_trans(Tween.TRANS_QUAD)
	spawn_tween.tween_method(_update_shader_with_tween_value, start_value, end_value, transition_duration)
	spawn_tween.tween_callback(func(): is_displaying = true)
	spawn_tween.tween_callback(transition_finish.emit)

func despawn_transtion():
	var start_value: float = _end_value
	var end_value: float = 0.0
	
	var despawn_tween: Tween = create_tween()
	despawn_tween.set_ease(Tween.EASE_OUT)
	despawn_tween.set_trans(Tween.TRANS_QUAD)
	despawn_tween.tween_method(_update_shader_with_tween_value, start_value, end_value, transition_duration)
	despawn_tween.tween_callback(func(): 
		is_displaying = false
		_packed_loaded_event_send = false
	)
	despawn_tween.tween_callback(transition_finish.emit)


func _update_shader_with_tween_value(value: float):
	var shader: ShaderMaterial = loading_page.material
	shader.set_shader_parameter("progress", value)
