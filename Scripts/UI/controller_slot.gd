extends Control
class_name ControllerSlot

@onready var label: Label = $Label
@onready var player_skin: TextureRect = $PlayerSkin
@onready var ready_container: VBoxContainer = $ReadyContainer
@onready var radial_progress_bar: ColorRect = $ReadyContainer/RadialProgressBar
@onready var ready_texture: TextureRect = $ReadyTexture

var _player_id: int = -1
var is_slot_available: bool:
	get(): return _player_id == -1
var is_ready: bool = false

@export var hold_duration: float = 0.75
var player_is_holding_ready_key: bool
var _hold_duration: float = 0.0

func _process(delta: float) -> void:
	if player_is_holding_ready_key and not is_ready:
		_hold_duration = move_toward(_hold_duration, 1.0, delta / hold_duration)
		
		if _hold_duration >= 1: 
			is_ready = true
			ready_texture.show()
	elif not is_ready:
		_hold_duration = move_toward(_hold_duration, 0.0, delta / hold_duration)
	
	radial_progress_bar.material.set_shader_parameter("progress", _hold_duration)

func set_player_id(new_id: int):
	_player_id = new_id
	
	label.hide()
	player_skin.show()
	ready_container.show()

func remove_player():
	_player_id = -1
	
	player_skin.hide()
	ready_container.hide()
	label.show()

## Return the player id connected to this slot, and -1 if there is any
func get_player_id() -> int:
	return _player_id

func back():
	if is_ready:
		ready_texture.hide()
		is_ready = false
	elif not is_slot_available:
		remove_player()
