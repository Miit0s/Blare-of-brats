extends Node3D
class_name CameraController

@onready var phantom_camera_3d: PhantomCamera3D = $MainCamera3D/PhantomCamera3D

@export var reset_position_duration: float = 1.5

var _start_focus: bool = false

var _start_position: Vector3

func _ready() -> void:
	_start_position = global_position

func add_player(new_player: Player):
	phantom_camera_3d.follow_targets.append(new_player.feet)

func start_tracking():
	_start_focus = true

func stop_tracking():
	_start_focus = false
	phantom_camera_3d.follow_targets.clear()
	
	#var reset_tween: Tween = create_tween()
	#reset_tween.set_ease(Tween.EASE_OUT)
	#reset_tween.set_trans(Tween.TRANS_BACK)
	#reset_tween.tween_property(self, "global_position", _start_position, reset_position_duration)
