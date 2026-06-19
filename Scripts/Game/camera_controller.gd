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
@export var damage_to_shake_movement_multiplier: float = 0.2
@export var directionnal_movement_on_hit_transition_duration: float = 0.1
@export var directionnal_movement_on_hit_back_transition_duration: float = 0.3

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
	normalized_direction.z = 0.0
	normalized_direction *= (damage * damage_to_shake_movement_multiplier)
	
	if normalized_direction != Vector3.ZERO:
		var directionnal_shake: Tween = create_tween()
		directionnal_shake.set_ease(Tween.EASE_OUT)
		directionnal_shake.set_trans(Tween.TRANS_QUAD)
		directionnal_shake.tween_property(follow_group_phantom_camera_3d, "follow_offset", normalized_direction, directionnal_movement_on_hit_transition_duration)
		directionnal_shake.tween_interval(hit_phantom_camera_noise_emitter_3d.duration)
		directionnal_shake.tween_property(follow_group_phantom_camera_3d, "follow_offset", Vector3.ZERO, directionnal_movement_on_hit_back_transition_duration)
	
	hit_phantom_camera_noise_emitter_3d.noise.frequency = _start_frequency_value + (damage * damage_to_shake_frequency_multiplier)
	
	hit_phantom_camera_noise_emitter_3d.emit()

func trigger_wall_fall_shake(duration: float):
	wall_fall_phantom_camera_noise_emitter_3d.duration = duration
	
	wall_fall_phantom_camera_noise_emitter_3d.emit()

func trigger_wolf_stun_shake():
	wolve_stun_phantom_camera_noise_emitter_3d.emit()

func trigger_objet_destruction_shake():
	object_destroy_phantom_camera_noise_emitter_3d.emit()
