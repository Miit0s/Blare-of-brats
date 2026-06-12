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

var _is_player_ready: bool = false

signal player_ready

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_text_for_current_id()

func _update_text_for_current_id():
	move_rich_text_label.raw_text = _get_correct_prefix_for_text(prefix_text_move)
	attack_rich_text_label_2.raw_text = _get_correct_prefix_for_text(prefix_text_attack)
	pickup_rich_text_label_3.raw_text = _get_correct_prefix_for_text(prefix_text_pickup)
	dash_rich_text_label_4.raw_text = _get_correct_prefix_for_text(prefix_text_dash)
	throw_rich_text_label_5.raw_text = _get_correct_prefix_for_text(prefix_text_throw)

func _get_correct_prefix_for_text(text: String) -> String:
	return "{" + text + "_" + str(player_input_id) + "}"

func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton and event.device == player_input_id:
		if event.is_action_pressed("JoinGame"):
			input_reminder_ready()
			get_viewport().set_input_as_handled()

func input_reminder_ready():
	if _is_player_ready: return
	
	not_ready.hide()
	ready_texture.show()
	
	_is_player_ready = true
	player_ready.emit()
