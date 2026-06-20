extends Control
class_name GameBar

@onready var shared_life_bar: SharedLifeBar = $SharedLifeBar
@onready var game_sound_bar: GameSoundBar = $GameSoundBar
@onready var round_win_indicator_left: RoundWinIndicator = $RoundWinIndicatorLeft
@onready var round_win_indicator_right: RoundWinIndicator = $RoundWinIndicatorRight

@export var player_health: float = 20
@export var sound_bar_max_volume: float = 100

var left_player_id: int = -1
var right_player_id: int = -1

signal sound_bar_fill

signal player_win(player_id: int)
signal lifebar_value_change(new_value: float)
signal lock_area_pass(lock_phase: int)

func _ready() -> void:
	shared_life_bar.player_health = player_health
	game_sound_bar.sound_bar_max_volume = sound_bar_max_volume
	
	game_sound_bar.sound_bar_fill.connect(_on_sound_bar_fill)
	game_sound_bar.lock_area_pass.connect(lock_area_pass.emit)
	shared_life_bar.player_win.connect(_on_player_win)
	shared_life_bar.lifebar_value_change.connect(_on_lifebar_value_change)

func setup_color_and_texture(left: PlayerCharacterSelection, right: PlayerCharacterSelection):
	left_player_id = left.player_id
	right_player_id = right.player_id
	
	round_win_indicator_left.apply_player_color(left.color_skin.main_color)
	round_win_indicator_right.apply_player_color(right.color_skin.main_color)
	
	shared_life_bar.change_player_data(left, right)

func add_player_win(player_id: int):
	if player_id == left_player_id:
		round_win_indicator_left.new_round_win()
	elif player_id == right_player_id:
		round_win_indicator_right.new_round_win()

func reset_all_bar():
	shared_life_bar.reset()
	game_sound_bar.reset()

func change_sound_bar_color(color: Color):
	game_sound_bar.change_sound_bar_color(color)

func _on_sound_bar_fill():
	sound_bar_fill.emit()

func _on_player_win(player_id: int):
	player_win.emit(player_id)

func _on_lifebar_value_change(new_value: float):
	lifebar_value_change.emit(new_value)
