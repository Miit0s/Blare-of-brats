extends Node3D
class_name GameScene

@onready var round_start_ui: RoundStartUI = $CanvasLayer/RoundStart
@onready var round_end_ui: RoundEnd = $CanvasLayer/RoundEnd
@onready var game_end_ui: GameEnd = $CanvasLayer/GameEnd

@export_category("Instance")
@export var shared_life_bar: SharedLifeBar
@export var game_sound_bar: GameSoundBar
@export var camera_controller: CameraController
@export var main_menu_scene_uid: String

@export_category("PartySetup")
@export var player_number: int = 2
@export var round_number: int = 3
@export var round_duration_sec: int = 300

@export_category("Sound")
@export var music_fight: WwiseEvent
@export var lead: WwiseRTPC
@export var round_state: WwiseState

@export_category("Level")
@export var possible_level: Array[PackedScene]

var players: Array[Player]
var players_win: Array[int]

var players_selection: Array[PlayerCharacterSelection] = []

var _current_scene: MapScene

func _ready() -> void:
	round_start_ui.start_round.connect(start_round)
	round_start_ui.animation_finish.connect(round_start_ui.hide)
	round_end_ui.animation_finish.connect(round_end_animaion_finish)
	round_end_ui.next_round_button_pressed.connect(start_round_animation)
	game_end_ui.to_main_menu_button_pressed.connect(return_to_main_menu)
	
	players_win.resize(player_number)
	players_win.fill(0)
	
	round_state.set_value()
	start_round_animation()

func start_round_animation():
	round_end_ui.hide()
	shared_life_bar.hide()
	game_sound_bar.hide()
	
	setup_new_scene()
	round_start_ui.show()
	round_start_ui.start_animation()

func start_round():
	shared_life_bar.reset()
	game_sound_bar.reset()
	
	shared_life_bar.show()
	game_sound_bar.show()
	
	for player in players:
		player.unfreeze()
	
	camera_controller.start_tracking()
	game_sound_bar.start_timer(round_duration_sec)
	
	music_fight.post(self)

func setup_new_scene():
	if _current_scene:
		_current_scene.queue_free()
	
	var new_scene: MapScene = possible_level.pick_random().instantiate()
	
	new_scene.item_will_be_delete.connect(_on_map_item_will_be_delete)
	new_scene.new_item_spawn.connect(_on_map_new_item_spawn)
	new_scene.new_player_spawn.connect(_on_map_new_player_spawn)
	
	new_scene.player_spawn_system.spawn_players(players_selection)
	
	_current_scene = new_scene
	
	add_child(new_scene)

func round_end_animaion_finish():
	if _check_if_game_end():
		round_end_ui.hide()
		game_end_ui.show()
		game_end_ui.start_animation(players_win.find(players_win.max()))
	else:
		round_end_ui.show_next_round_button()

func player_win(player_id: int):
	players_win[player_id] += 1
	
	for player in players:
		player.freeze()
	players.clear()
	camera_controller.stop_tracking()
	
	music_fight.stop(self)
	
	round_end_ui.show()
	round_end_ui.start_animation(players_win)

func return_to_main_menu():
	get_tree().change_scene_to_file(main_menu_scene_uid)

func _on_shared_life_bar_player_win(player_id: int) -> void:
	print("No more health trigger")
	player_win(player_id)


func _on_game_sound_bar_sound_bar_fill() -> void:
	print("Sound bar fill trigger")
	player_win(shared_life_bar.get_player_id_with_most_health())


func lifebar_value_change(lifebar_value: float):
	lead.set_value(self, lifebar_value * 100)


func _on_map_item_will_be_delete(item: Item) -> void:
	item.sound_made.disconnect(game_sound_bar.add_sound_to_bar)


func _on_map_new_item_spawn(new_item: Item) -> void:
	new_item.sound_made.connect(game_sound_bar.add_sound_to_bar)


func _on_map_new_player_spawn(player: Player) -> void:
	player.freeze()
	camera_controller.add_player(player)
	player.has_been_hit.connect(shared_life_bar.add_damage_to_player)
	
	players.append(player)

func _check_if_game_end() -> bool:
	var rounds_played: int = 0
	for score in players_win: 
		rounds_played += score
	
	var missing_round = round_number - rounds_played
	
	var players_win_sorted: Array[int] = players_win.duplicate()
	players_win_sorted.sort_custom(func(a, b): return a > b)
	
	if (players_win_sorted[0] - players_win_sorted[1]) > missing_round: return true
	if missing_round <= 0: return true
	
	return false
