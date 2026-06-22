extends Control

@onready var play_button: TextureButton = $MainStack/MainButton/ControlPlay/Play
@onready var options_button: TextureButton = $MainStack/MainButton/ControlOptions/Options
@onready var credits_button: TextureButton = $MainStack/MainButton/ControlCredits/Credits
@onready var exit_button: TextureButton = $MainStack/MainButton/ControlExit/Exit

@onready var quit_prompt: Control = $QuitPrompt
@onready var credits: Control = $Credits
@onready var options: Control = $Options

@onready var background: TextureRect = $Background/ImageBackground
@onready var screen_center: Vector2 = get_viewport_rect().size / 2

@export var game_start_scene_uid: String

@export_category("Background Move")
@export var move_offset: float = 5.0
@export var move_speed: float = 0.2
@export var buttons_impacting_movement: Array[BaseButton]

@export_category("Vibration")
@export_range(0, 1) var vibration_force_on_button_change: float = 0.1
@export var vibration_duration_on_button_change: float = 0.1

var _previous_button_pos: Vector2 = Vector2.ZERO
var _move_tween: Tween = null

var _last_device_to_move: int = -1

func _ready() -> void:
	for button in buttons_impacting_movement:
		button.focus_entered.connect(_on_button_focus_entered.bind(button))
	
	if LoadingPage.is_displaying:
		LoadingPage.despawn_transtion()
	
	if not GameOptions.have_launch_game:
		play_button.grab_focus()

func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton and not GameOptions.have_launch_game:
		GameOptions.have_launch_game = true
		var menu_start_scene: MenuStartScreen = $MenuStartScreen
		menu_start_scene.play_transtion_and_destroy()
		get_viewport().set_input_as_handled()
		
		play_button.grab_focus()
	elif not GameOptions.have_launch_game:
		get_viewport().set_input_as_handled()
	
	if event.is_action("ui_up") or event.is_action("ui_down") or event.is_action("ui_left") or event.is_action("ui_right"):
		_last_device_to_move = event.device

func _on_play_pressed() -> void:
	LoadingPage.packed_scene_loaded.connect(get_tree().change_scene_to_packed, ConnectFlags.CONNECT_ONE_SHOT)
	LoadingPage.start_transtion_to_scene(game_start_scene_uid)


func _on_options_pressed() -> void:
	options.show()


func _on_credits_pressed() -> void:
	credits.show()


func _on_exit_pressed() -> void:
	quit_prompt.show()


func _on_quit_prompt_visibility_changed() -> void:
	if not quit_prompt.visible:
		exit_button.grab_focus()


func _on_credits_visibility_changed() -> void:
	if not credits.visible:
		credits_button.grab_focus()

func _on_button_focus_entered(button: BaseButton) -> void:
	VibrationManager.start_joy_vibration(_last_device_to_move, vibration_force_on_button_change, 0, vibration_duration_on_button_change)
	
	if _previous_button_pos == Vector2.ZERO:
		_previous_button_pos = button.global_position
		return
	
	var button_direction: float = button.global_position.y - _previous_button_pos.y
	var y_offset = sign(button_direction) * move_offset
	
	_previous_button_pos = button.global_position
	
	_move_tween = create_tween()
	_move_tween.set_ease(Tween.EASE_IN_OUT)
	_move_tween.set_trans(Tween.TRANS_QUAD)
	_move_tween.tween_property(background, "position", background.position + Vector2(0, y_offset), move_speed)
	
	_move_tween.finished.connect(func(): _move_tween = null)
