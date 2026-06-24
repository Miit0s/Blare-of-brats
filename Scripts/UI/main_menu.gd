extends Control

@onready var play_button: TextureButton = $MainStack/MainButton/ControlPlay/Play
@onready var options_button: TextureButton = $MainStack/MainButton/ControlOptions/Options
@onready var credits_button: TextureButton = $MainStack/MainButton/ControlCredits/Credits
@onready var exit_button: TextureButton = $MainStack/MainButton/ControlExit/Exit

@onready var quit_prompt: QuitPromptUI = $QuitPrompt
@onready var credits: CreditsUI = $Credits
@onready var options: OptionsUI = $Options

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

@export_category("Sound")
@export var on_button_focus: WwiseEvent
@export var on_button_click: WwiseEvent

var _previous_button_pos: Vector2 = Vector2.ZERO
var _move_tween: Tween = null

var _last_device_to_move: int = -1

var _dont_trigger_next_focus: bool = false

func _ready() -> void:
	for button in buttons_impacting_movement:
		button.focus_entered.connect(_on_button_focus_entered.bind(button))
	
	play_button.pressed.connect(_on_play_pressed, ConnectFlags.CONNECT_ONE_SHOT)
	options.visibility_changed.connect(_on_settings_visibility_change)
	
	credits.on_button_click = on_button_click
	
	quit_prompt.on_button_click = on_button_click
	quit_prompt.on_button_focus = on_button_focus
	
	options.on_button_click = on_button_click
	options.on_button_focus = on_button_focus
	
	if LoadingPage.is_displaying:
		LoadingPage.despawn_transtion()
	
	if GameOptions.have_launch_game:
		play_button.grab_focus()
		MainMusicManager.set_main_menu_state()
	else:
		MainMusicManager.set_start_menu_state()

func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton and not GameOptions.have_launch_game:
		GameOptions.have_launch_game = true
		
		var menu_start_scene: MenuStartScreen = $MenuStartScreen
		menu_start_scene.play_transtion_and_destroy()
		get_viewport().set_input_as_handled()
		
		play_button.grab_focus()
		MainMusicManager.set_main_menu_state()
	elif not GameOptions.have_launch_game:
		get_viewport().set_input_as_handled()
	
	if event.is_action("ui_up") or event.is_action("ui_down") or event.is_action("ui_left") or event.is_action("ui_right"):
		_last_device_to_move = event.device

func _on_play_pressed() -> void:
	on_button_click.post(self)
	LoadingPage.packed_scene_loaded.connect(get_tree().change_scene_to_packed, ConnectFlags.CONNECT_ONE_SHOT)
	LoadingPage.start_transtion_to_scene(game_start_scene_uid)


func _on_options_pressed() -> void:
	options.show()
	on_button_click.post(self)
	_dont_trigger_next_focus = true


func _on_credits_pressed() -> void:
	credits.show()
	on_button_click.post(self)
	_dont_trigger_next_focus = true


func _on_exit_pressed() -> void:
	quit_prompt.show()
	on_button_click.post(self)
	_dont_trigger_next_focus = true


func _on_quit_prompt_visibility_changed() -> void:
	if not quit_prompt.visible:
		exit_button.grab_focus()


func _on_credits_visibility_changed() -> void:
	if not credits.visible:
		credits_button.grab_focus()

func _on_settings_visibility_change():
	if not options.visible:
		options_button.grab_focus()

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
	
	if not _dont_trigger_next_focus:
		on_button_focus.post(self)
	else:
		_dont_trigger_next_focus = false
