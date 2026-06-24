extends Control
class_name GameEnd

@onready var restart_button: CustomTextureButton = $HBoxContainer/StatsHolder/ButtonContainer/RestartButton
@onready var to_main_menu_button: CustomTextureButton = $HBoxContainer/StatsHolder/ButtonContainer/ToMainMenuButton

@onready var left_side_control: Control = $LeftSideControl
@onready var right_side_control: Control = $RightSideControl

@onready var score_left: Label = $HBoxContainer/StatsHolder/HBoxContainer/ScoreLeft
@onready var score_right: Label = $HBoxContainer/StatsHolder/HBoxContainer/ScoreRight

@onready var stats_container: VBoxContainer = $HBoxContainer/StatsHolder/StatsContainer
@onready var damage_end_game_result_bar: EndGameResultBar = $HBoxContainer/StatsHolder/StatsContainer/DamageEndGameResultBar
@onready var item_broken_end_game_result_bar: EndGameResultBar = $HBoxContainer/StatsHolder/StatsContainer/ItemBrokenEndGameResultBar
@onready var noise_made_end_game_result_bar: EndGameResultBar = $HBoxContainer/StatsHolder/StatsContainer/NoiseMadeEndGameResultBar
@onready var ballon_pop_end_game_result_bar: EndGameResultBar = $HBoxContainer/StatsHolder/StatsContainer/BallonPopEndGameResultBar
@onready var button_container: VBoxContainer = $HBoxContainer/StatsHolder/ButtonContainer

@export_category("LooseWinScene")
@export var winning_scene: PackedScene
@export var loosing_scene: PackedScene
@export var anchor_preset: Control.LayoutPreset
@export var left_position: Vector2
@export var right_position: Vector2

@export_category("Tween")
@export var bar_spawn_animation_stagger_delay: float = 0.15
@export var bar_alpha_transition_duration: float = 0.4
@export var wait_delay_before_stage_reveal: float = 0.5

@export_category("Onboarding")
@export var only_next_scene_button: bool = false

@export_category("Sound")
@export var score_increment_sound: WwiseEvent


signal restart_button_pressed
signal to_main_menu_button_pressed

func _ready() -> void:
	restart_button.pressed.connect(restart_button_pressed.emit)
	to_main_menu_button.pressed.connect(to_main_menu_button_pressed.emit)
	
	if only_next_scene_button:
		restart_button.hide()
		to_main_menu_button.label.text = "Continue"
	
	left_side_control.remove_child(left_side_control.get_child(0))
	right_side_control.remove_child(right_side_control.get_child(0))

func setup_scene_and_start_animation(left_player_info: EndGameResource, right_player_info: EndGameResource):
	left_side_control.hide()
	right_side_control.hide()
	
	var left_side_scene: SideEndScreen
	var right_side_scene: SideEndScreen
	if left_player_info.is_winner:
		left_side_scene = winning_scene.instantiate()
		right_side_scene = loosing_scene.instantiate()
	else:
		left_side_scene = loosing_scene.instantiate()
		right_side_scene = winning_scene.instantiate()
	
	left_side_control.add_child(left_side_scene)
	right_side_control.add_child(right_side_scene)
	
	left_side_scene.set_anchors_preset(anchor_preset)
	left_side_scene.set_position(left_position)
	left_side_scene.apply_color(left_player_info.character_color)
	
	right_side_scene.set_anchors_preset(anchor_preset)
	right_side_scene.set_position(right_position)
	right_side_scene.apply_color(right_player_info.character_color)
	
	calculate_ratio(damage_end_game_result_bar, left_player_info.damage, right_player_info.damage)
	calculate_ratio(item_broken_end_game_result_bar, left_player_info.item_broken, right_player_info.item_broken)
	calculate_ratio(noise_made_end_game_result_bar, left_player_info.noise_made, right_player_info.noise_made)
	calculate_ratio(ballon_pop_end_game_result_bar, left_player_info.ballon_popped, right_player_info.ballon_popped)
	
	score_left.text = str(left_player_info.score)
	score_right.text = str(right_player_info.score)
	
	for child: Control in stats_container.get_children():
		child.modulate.a = 0.0
	
	stats_container.show()
	
	var spawn_animation: Tween = create_tween()
	spawn_animation.set_ease(Tween.EASE_OUT)
	spawn_animation.set_trans(Tween.TRANS_QUAD)
	
	for i in range(stats_container.get_child_count()):
		var child = stats_container.get_child(i)
		var delay = i * bar_spawn_animation_stagger_delay
		
		spawn_animation.parallel().tween_property(child, "modulate:a", 1.0, bar_alpha_transition_duration).set_delay(delay)
		spawn_animation.parallel().tween_callback(score_increment_sound.post.bind(self)).set_delay(delay)
	
	spawn_animation.tween_callback(score_left.show)
	spawn_animation.parallel().tween_callback(score_right.show)
	spawn_animation.parallel().tween_callback(MainMusicManager.set_win_state)
	spawn_animation.tween_interval(wait_delay_before_stage_reveal)
	spawn_animation.tween_callback(left_side_control.show)
	spawn_animation.parallel().tween_callback(right_side_control.show)
	spawn_animation.tween_callback(button_container.show)
	spawn_animation.tween_callback(focus_on_return_menu_button)

func focus_on_return_menu_button():
	if only_next_scene_button:
		to_main_menu_button.texture_button.grab_focus()
	else:
		restart_button.texture_button.grab_focus()

func calculate_ratio(bar_to_modify: EndGameResultBar, left_result: float, right_result: float):
	var ratio: float = 0.5
	if not left_result + right_result == 0:
		ratio = left_result / (left_result + right_result)
	
	ratio = clampf(ratio, 0.10, 0.90)
	bar_to_modify.progress = ratio
