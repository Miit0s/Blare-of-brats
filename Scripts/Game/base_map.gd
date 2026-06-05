extends Node3D
class_name BaseMap

@onready var wolf_tracking_spot: TrackingSpot = $WolfTrackingSpot

@export var lights_to_control: Array[Light3D]

func desactivate_light():
	for light in lights_to_control:
		light.hide()

func activate_wolf_light():
	wolf_tracking_spot.show()

func desactivate_wolf_light():
	wolf_tracking_spot.hide()
