extends Node3D
class_name BaseMap

@onready var wolf_tracking_spot: TrackingSpot = $WolfTrackingSpot
@onready var wolf_eye_start_target: Marker3D = $WolfEyeStartTarget
@onready var wolf_target: WolfTarget = $WolfTarget
@onready var spawn_area_3d: SpawnArea3D = $SpawnArea3D
@onready var cutscene_phantom_camera_3d: PhantomCamera3D = $CutscenePhantomCamera3D
@onready var wolf_eyes_wake_up: GPUParticles3D = $WolfEyesWakeUp

@export var lights_to_control: Array[Light3D]

@export_category("Wolf Eye Timer")
@export var destination_reach_wait_time: float = 1
@export var hit_player_wait_time: float = 5

@export_category("Wolf Cutscene")
@export var wait_duration_before_camera_change: float = 1.0
@export var wait_duration_before_eyes_animation: float = 0.8
@export var eyes_wake_up_vibration_force: float = 1.0
@export var eyes_wake_up_vibration_duration: float = 0.5

var _random_position_wait_tween: Tween = null

signal wolf_has_hit_player
signal cutscene_finish

func _ready() -> void:
	wolf_target.has_reach_destination.connect(wait_and_set_random_target)
	wolf_target.has_hit_player.connect(reset_wolf_light)
	wolf_target.has_hit_player.connect(wolf_has_hit_player.emit)

func start_wolf_cutscene(controller_id_for_vibration: Array[int]):
	var wolf_cutscene_tween: Tween = create_tween()
	wolf_cutscene_tween.tween_callback(desactivate_light)
	wolf_cutscene_tween.tween_interval(wait_duration_before_camera_change)
	wolf_cutscene_tween.tween_callback(func(): cutscene_phantom_camera_3d.priority = 2)
	wolf_cutscene_tween.tween_interval(wait_duration_before_eyes_animation)
	wolf_cutscene_tween.tween_callback(wolf_eyes_wake_up.restart)
	wolf_cutscene_tween.tween_callback(_trigger_wolf_eyes_vibration.bind(controller_id_for_vibration))
	wolf_cutscene_tween.tween_interval(wolf_eyes_wake_up.lifetime)
	wolf_cutscene_tween.tween_callback(func(): cutscene_phantom_camera_3d.priority = 0)
	wolf_cutscene_tween.tween_callback(cutscene_finish.emit)

func start_simple_cutscene(controller_id_for_vibration: Array[int]):
	var wolf_cutscene_tween: Tween = create_tween()
	wolf_cutscene_tween.tween_callback(desactivate_light)
	wolf_cutscene_tween.tween_interval(wait_duration_before_camera_change)
	wolf_cutscene_tween.tween_callback(wolf_eyes_wake_up.restart)
	wolf_cutscene_tween.tween_callback(_trigger_wolf_eyes_vibration.bind(controller_id_for_vibration))
	wolf_cutscene_tween.tween_interval(wolf_eyes_wake_up.lifetime)
	wolf_cutscene_tween.tween_callback(cutscene_finish.emit)

func desactivate_light():
	for light in lights_to_control:
		light.hide()

func activate_wolf_light():
	wolf_target.global_position = wolf_eye_start_target.global_position
	set_random_target_for_wolf()
	wolf_tracking_spot.show()
	wolf_target.start_tracking()

func desactivate_wolf_light():
	wolf_target.stop_tracking()
	wolf_tracking_spot.hide()
	wolf_target.go_directly_to(wolf_eye_start_target.global_position)

func set_new_wolf_eye_target(new_position: Vector3):
	if _random_position_wait_tween:
		_random_position_wait_tween.kill()
		_random_position_wait_tween = null
	
	wolf_target.set_new_target_position(new_position)

func set_random_target_for_wolf():
	var new_position: Vector3 = await spawn_area_3d.point()
	wolf_target.set_new_target_position(to_global(new_position))

func reset_wolf_light():
	desactivate_wolf_light()
	await get_tree().create_timer(hit_player_wait_time).timeout
	activate_wolf_light()

func wait_and_set_random_target():
	if _random_position_wait_tween:
		_random_position_wait_tween.kill()
	
	_random_position_wait_tween = create_tween()
	_random_position_wait_tween.tween_interval(destination_reach_wait_time)
	_random_position_wait_tween.tween_callback(set_random_target_for_wolf)

func _trigger_wolf_eyes_vibration(controller_id_for_vibration: Array[int]):
	for id in controller_id_for_vibration:
		VibrationManager.start_joy_vibration(id, eyes_wake_up_vibration_force, 0.0, eyes_wake_up_vibration_duration)
