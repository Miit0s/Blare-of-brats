extends Control

@onready var play_button: TextureButton = $MainButton/ControlPlay/Play
@onready var options_button: TextureButton = $MainButton/ControlOptions/Options
@onready var credits_button: TextureButton = $MainButton/ControlCredits/Credits
@onready var exit_button: TextureButton = $MainButton/ControlExit/Exit

@onready var quit_prompt: Control = $QuitPrompt
@onready var credits: Control = $Credits
@onready var options: Control = $Options

@onready var background: TextureRect = $Background
@onready var screen_center: Vector2 = get_viewport_rect().size / 2

@export var game_start_scene_uid: String

@export_category("Background Move")
@export var max_offset: float = 30.0
@export var lerp_speed: float = 5.0
@export var buttons_impacting_movement: Array[BaseButton]

var target_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	target_offset = background.position
	
	for button in buttons_impacting_movement:
		button.focus_entered.connect(_on_button_focus_entered.bind(button))
	
	play_button.grab_focus()

func _process(delta: float) -> void:
	background.position = background.position.lerp(target_offset, lerp_speed * delta)

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(game_start_scene_uid)


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
	var button_center = button.global_position + (button.size / 2)
	var direction = (button_center - screen_center) / screen_center
	
	target_offset = (-Vector2(0, direction.y) * max_offset) + Vector2(target_offset.x, 0)
