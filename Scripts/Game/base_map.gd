extends Node3D
class_name BaseMap

@onready var wolf_tracking_spot: TrackingSpot = $WolfTrackingSpot
@onready var wolf_eye_start_target: Marker3D = $WolfEyeStartTarget
@onready var wolf_target: WolfTarget = $WolfTarget
@onready var spawn_area_3d: SpawnArea3D = $SpawnArea3D

@export var lights_to_control: Array[Light3D]

@export_category("Wolf Eye Timer")
@export var destination_reach_wait_time: float = 1
@export var hit_player_wait_time: float = 5

signal wolf_has_hit_player

func _ready() -> void:
	wolf_target.has_reach_destination.connect(wait_and_set_random_target)
	wolf_target.has_hit_player.connect(reset_wolf_light)
	wolf_target.has_hit_player.connect(wolf_has_hit_player.emit)

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
	wolf_target.set_new_target_position(new_position)

func set_random_target_for_wolf():
	var new_position: Vector3 = await spawn_area_3d.point()
	wolf_target.set_new_target_position(to_global(new_position))

func reset_wolf_light():
	desactivate_wolf_light()
	await get_tree().create_timer(hit_player_wait_time).timeout
	activate_wolf_light()

func wait_and_set_random_target():
	await get_tree().create_timer(destination_reach_wait_time).timeout
	set_random_target_for_wolf()
