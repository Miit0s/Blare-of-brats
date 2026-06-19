extends Node3D
class_name CameraController

@onready var follow_group_phantom_camera_3d: PhantomCamera3D = $FollowGroupPhantomCamera3D
@onready var hit_phantom_camera_noise_emitter_3d: PhantomCameraNoiseEmitter3D = $HitPhantomCameraNoiseEmitter3D
@onready var wall_fall_phantom_camera_noise_emitter_3d: PhantomCameraNoiseEmitter3D = $WallFallPhantomCameraNoiseEmitter3D
@onready var wolve_stun_phantom_camera_noise_emitter_3d: PhantomCameraNoiseEmitter3D = $WolfStunPhantomCameraNoiseEmitter3D
@onready var object_destroy_phantom_camera_noise_emitter_3d: PhantomCameraNoiseEmitter3D = $ObjectDestroyPhantomCameraNoiseEmitter3D

@export var reset_position_duration: float = 1.5

@export_category("Camera Shake")
@export var damage_to_shake_frequency_multiplier: float = 2.0

var _temp_player: Array[Node3D]

var _start_frequency_value: float = 0.0

func _ready() -> void:
	_start_frequency_value = hit_phantom_camera_noise_emitter_3d.noise.frequency

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

func trigger_hit_shake(direction: Vector3, damage: float):
	var normalized_direction: Vector3 = direction.normalized()
	
	if normalized_direction != Vector3.ZERO:
		#TODO: Need to test the case when the hit is comming from the left, because there is a chance that the noise multiplier will be set to zero instead of going to the left like inteaded
		hit_phantom_camera_noise_emitter_3d.noise.positional_multiplier_x = normalized_direction.x
		hit_phantom_camera_noise_emitter_3d.noise.positional_multiplier_y = normalized_direction.y
	else:
		hit_phantom_camera_noise_emitter_3d.noise.positional_multiplier_x = 1.0
		hit_phantom_camera_noise_emitter_3d.noise.positional_multiplier_y = 1.0
	
	hit_phantom_camera_noise_emitter_3d.noise.frequency = _start_frequency_value + (damage * damage_to_shake_frequency_multiplier)
	
	hit_phantom_camera_noise_emitter_3d.emit()

func trigger_wall_fall_shake(duration: float):
	wall_fall_phantom_camera_noise_emitter_3d.duration = duration
	
	wall_fall_phantom_camera_noise_emitter_3d.emit()

func trigger_wolf_stun_shake():
	wolve_stun_phantom_camera_noise_emitter_3d.emit()

func trigger_objet_destruction_shake():
	object_destroy_phantom_camera_noise_emitter_3d.emit()
