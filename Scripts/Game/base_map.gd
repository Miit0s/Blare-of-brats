extends Node3D
class_name BaseMap

@onready var wolf_tracking_spot: TrackingSpot = $WolfTrackingSpot
@onready var wolf_eye_start_target: Marker3D = $WolfEyeStartTarget
@onready var wolf_target: WolfTarget = $WolfTarget
@onready var spawn_area_3d: SpawnArea3D = $SpawnArea3D

@export var lights_to_control: Array[Light3D]

func _ready() -> void:
	wolf_target.has_reach_destination.connect(set_random_target_for_wolf)

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

func set_new_wolf_eye_target(new_position: Vector3):
	wolf_target.set_new_target_position(new_position)

func set_random_target_for_wolf():
	var new_position: Vector3 = await spawn_area_3d.point()
	wolf_target.set_new_target_position(to_global(new_position))

func reset_wolf_light(duration: float):
	desactivate_wolf_light()
	await get_tree().create_timer(duration).timeout
	activate_wolf_light()
