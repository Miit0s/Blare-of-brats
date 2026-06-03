extends Node3D
class_name CameraController

@onready var follow_group_phantom_camera_3d: PhantomCamera3D = $FollowGroupPhantomCamera3D

@export var reset_position_duration: float = 1.5

var _temp_player: Array[Node3D]

func add_player(new_player: Player):
	_temp_player.append(new_player)

func start_tracking():
	follow_group_phantom_camera_3d.append_follow_targets_array(_temp_player)
	follow_group_phantom_camera_3d.set_priority(2)

func stop_tracking():
	follow_group_phantom_camera_3d.set_priority(0)
	for player in _temp_player:
		follow_group_phantom_camera_3d.erase_follow_targets(player)
	_temp_player.clear()
