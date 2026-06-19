extends Control
class_name InputReminder

@onready var not_ready: TextureRect = $NotReady
@onready var ready_texture: TextureRect = $Ready

@export var move_rich_text_label: ControllerIconParser
@export var attack_rich_text_label_2: ControllerIconParser
@export var pickup_rich_text_label_3: ControllerIconParser
@export var dash_rich_text_label_4: ControllerIconParser
@export var throw_rich_text_label_5: ControllerIconParser

@export var player_input_id: int = 0:
	set(new_value):
		player_input_id = new_value
		_update_text_for_current_id()

@export_category("Action")
@export var prefix_text_move: String
@export var prefix_text_attack: String
@export var prefix_text_pickup: String
@export var prefix_text_dash: String
@export var prefix_text_throw: String

@export_category("Tween")
@export var self_spawn_tween_duration: float = 0.2
@export var ready_tween_duration: float = 0.2

var vibration_force_on_ready: float = 0.0
var vibration_duration_on_ready: float = 0.1

var _is_player_ready: bool = false

signal player_ready

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_text_for_current_id()
	self.scale = Vector2.ZERO

func _update_text_for_current_id():
	move_rich_text_label.raw_text = _get_correct_prefix_for_text(prefix_text_move)
	attack_rich_text_label_2.raw_text = _get_correct_prefix_for_text(prefix_text_attack)
	pickup_rich_text_label_3.raw_text = _get_correct_prefix_for_text(prefix_text_pickup)
	dash_rich_text_label_4.raw_text = _get_correct_prefix_for_text(prefix_text_dash)
	throw_rich_text_label_5.raw_text = _get_correct_prefix_for_text(prefix_text_throw)

func _get_correct_prefix_for_text(text: String) -> String:
	return "{" + text + "_" + str(player_input_id) + "}"

func _input(event: InputEvent) -> void:
	if not visible: return
	
	if event is InputEventJoypadButton and event.device == player_input_id:
		if event.is_action_pressed("JoinGame"):
			input_reminder_ready()
			VibrationManager.start_joy_vibration(player_input_id, vibration_force_on_ready, 0, vibration_duration_on_ready)
			get_viewport().set_input_as_handled()

func input_reminder_ready():
	if _is_player_ready: return
	
	not_ready.hide()
	
	ready_texture.scale = Vector2.ZERO
	ready_texture.show()
	
	var ready_texture_tween: Tween = create_tween()
	ready_texture_tween.set_ease(Tween.EASE_OUT)
	ready_texture_tween.set_trans(Tween.TRANS_QUART)
	ready_texture_tween.tween_property(ready_texture, "scale", Vector2.ONE, ready_tween_duration)
	
	await ready_texture_tween.finished
	
	_is_player_ready = true
	player_ready.emit()

func trigger_spawn_animation():
	var self_spawn_tween: Tween = create_tween()
	self_spawn_tween.set_ease(Tween.EASE_OUT)
	self_spawn_tween.set_trans(Tween.TRANS_QUART)
	self_spawn_tween.tween_property(self, "scale", Vector2.ONE, self_spawn_tween_duration)

func trigger_despawn_animation():
	var self_despawn_tween: Tween = create_tween()
	self_despawn_tween.set_ease(Tween.EASE_IN)
	self_despawn_tween.set_trans(Tween.TRANS_QUART)
	self_despawn_tween.tween_property(self, "scale", Vector2.ZERO, self_spawn_tween_duration)
	self_despawn_tween.tween_property(self, "visible", false, 0)
