extends Node3D
class_name GameScene

@onready var round_start_ui: RoundStartUI = $CanvasLayer/RoundStart
@onready var round_end_ui: RoundEnd = $CanvasLayer/RoundEnd
@onready var game_end_ui: GameEnd = $CanvasLayer/GameEnd

@export_category("Instance")
@export var game_bar: GameBar
@export var camera_controller: CameraController
@export var next_scene_uid: String

@export var tracking_spot_player_one: TrackingSpot
@export var tracking_spot_player_two: TrackingSpot

@export_category("PartySetup")
@export var player_number: int = 2
@export var round_number: int = 3

@export_category("Sound")
@export var music_fight: WwiseEvent
@export var countdown: WwiseEvent
@export var lead: WwiseRTPC
@export_group("Soundbar related sound")
@export var round_start_state: WwiseState
@export var second_phase_state: WwiseState
@export var third_phase_state: WwiseState
@export var danger_phase_start: WwiseState
@export var soundbar_lvl1: WwiseEvent
@export var soundbar_lvl2: WwiseEvent
@export var bar_volume_rtpc: WwiseRTPC
@export_group("Crowd")
@export var crowd_reaction_duration: float = 1.5
@export var continious_crowd_switch: WwiseSwitch
@export var reaction_crowd_switch: WwiseSwitch
@export var danger_phase_crowd_switch: WwiseSwitch
@export var crowd_sound : WwiseEvent

@export_category("Vibration")
@export_group("Round Begin")
@export_range(0, 1) var round_begin_vibration_force: float = 0.5
@export var round_begin_vibration_duration: float = 0.2

@export_group("Round End")
@export_range(0, 1) var round_end_vibration_force: float = 0.5
@export var round_end_vibration_duration: float = 0.5

@export_category("Level")
@export var possible_level: Array[PackedScene]

var players: Array[Player]
var players_win: Array[int]
var _last_player_win_id: int = -1

var players_selection: Array[PlayerCharacterSelection] = [preload("uid://4w1f5mgj2e5s"), preload("uid://cligadeo7a6fk")]

var _current_scene: MapScene
var _round_ended: bool = false

func _ready() -> void:
	round_start_ui.start_round.connect(start_round)
	round_start_ui.animation_finish.connect(round_start_ui.hide)
	round_end_ui.animation_finish.connect(round_end_animaion_finish)
	round_end_ui.next_round_button_pressed.connect(start_round_animation)
	game_end_ui.to_main_menu_button_pressed.connect(go_to_next_scene)
	
	game_bar.player_win.connect(_on_shared_life_bar_player_win)
	game_bar.sound_bar_fill.connect(_on_game_sound_bar_sound_bar_fill)
	game_bar.lifebar_value_change.connect(lifebar_value_change)
	game_bar.shared_life_bar.player_have_reach_min_life.connect(_trigger_crowd_reaction)
	game_bar.lock_area_pass.connect(_on_soundbar_lock_area_pass)
	
	players_win.resize(player_number)
	players_win.fill(0)
	
	start_round_animation()

func _process(_delta: float) -> void:
	bar_volume_rtpc.set_value(self, game_bar.game_sound_bar._game_sound_bar_volume * 100)

func start_round_animation():
	round_end_ui.hide()
	game_bar.hide()
	
	countdown.post(self)
	
	round_start_state.set_value()
	
	game_bar.setup_color_and_texture(players_selection[0], players_selection[1])
	round_end_ui.change_player_data(players_selection[0], players_selection[1])
	
	setup_new_scene()
	round_start_ui.show()
	round_start_ui.start_animation()

func start_round():
	game_bar.reset_all_bar()
	game_bar.shared_life_bar.unlock()
	
	_round_ended = false
	
	game_bar.show()
	
	for player in players:
		VibrationManager.start_joy_vibration(player.player_id, round_begin_vibration_force, 0, round_begin_vibration_duration)
		player.unfreeze()
	
	camera_controller.start_tracking()
	
	music_fight.post(self)
	crowd_sound.post(self)

func setup_new_scene():
	if _current_scene:
		_current_scene.queue_free()
	
	var new_scene: MapScene = possible_level.pick_random().instantiate()
	
	new_scene.item_will_be_delete.connect(_on_map_item_will_be_delete)
	new_scene.new_item_spawn.connect(_on_map_new_item_spawn)
	new_scene.new_player_spawn.connect(_on_map_new_player_spawn)
	new_scene.balloon_pop.connect(_item_made_sound)
	
	new_scene.player_spawn_system.spawn_players(players_selection)
	
	new_scene.wolf_has_hit_player.connect(camera_controller.trigger_wolf_stun_shake)
	
	_current_scene = new_scene
	
	add_child(new_scene)

func round_end_animaion_finish():
	var winner_data: PlayerCharacterSelection = _get_player_selection(_last_player_win_id)
	game_bar.add_player_win(_last_player_win_id)
	
	if _check_if_game_end():
		round_end_ui.hide()
		game_end_ui.show()
		game_end_ui.start_animation(_last_player_win_id, winner_data.color_skin.main_color, players_selection[0].player_id)
	else:
		round_end_ui.show_next_round_button()

func player_win(player_id: int):
	if _round_ended: return
	
	_round_ended = true
	players_win[player_id] += 1
	_last_player_win_id = player_id
	
	game_bar.shared_life_bar.lock()
	
	for player in players:
		player.reset_vibration()
		VibrationManager.start_joy_vibration(player.player_id, round_end_vibration_force, 0, round_end_vibration_duration)
		player.freeze()
	players.clear()
	camera_controller.stop_tracking()
	tracking_spot_player_one.target = null
	tracking_spot_player_two.target = null
	
	music_fight.stop(self)
	
	round_end_ui.show()
	round_end_ui.start_animation(player_id, players_win, _get_player_selection(player_id).color_skin.main_color)

func go_to_next_scene():
	get_tree().change_scene_to_file(next_scene_uid)


func _on_shared_life_bar_player_win(player_id: int) -> void:
	player_win(player_id)


func _on_game_sound_bar_sound_bar_fill() -> void:
	_activate_the_danger_phase()


func lifebar_value_change(lifebar_value: float):
	lead.set_value(self, lifebar_value * 100)


func _on_map_item_will_be_delete(item: Item) -> void:
	item.sound_made.disconnect(_item_made_sound)
	camera_controller.trigger_objet_destruction_shake()


func _on_map_new_item_spawn(new_item: Item) -> void:
	new_item.sound_made.connect(_item_made_sound)


func _item_made_sound(value: float, sound_global_position: Vector3):
	game_bar.game_sound_bar.add_sound_to_bar(value)
	_current_scene.sound_made_at_location(sound_global_position)


func _on_map_new_player_spawn(player: Player) -> void:
	camera_controller.add_player(player)
	
	if tracking_spot_player_one.target:
		tracking_spot_player_two.target = player
	else:
		tracking_spot_player_one.target = player
	
	player.freeze()
	player.has_been_hit.connect(_player_has_been_hit)
	
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

func _get_player_selection(player_id: int) -> PlayerCharacterSelection:
	if players_selection[0].player_id == player_id:
		return players_selection[0]
	return players_selection[1]

func _activate_the_danger_phase():
	_current_scene.activate_danger_phase()
	danger_phase_start.set_value()
	danger_phase_crowd_switch.set_value(self)
	
	await get_tree().create_timer(2).timeout
	
	_current_scene.activate_wolf_tracking_spot()
	game_bar.change_sound_bar_color(Color(1.0, 0.0, 0.0, 1.0))

func _on_soundbar_lock_area_pass(lock_phase: int):
	match lock_phase:
		0: 
			round_start_state.set_value()
		1: 
			second_phase_state.set_value()
			soundbar_lvl1.post(self)
		2: 
			third_phase_state.set_value()
			soundbar_lvl2.post(self)

func _trigger_crowd_reaction():
	reaction_crowd_switch.set_value(self)
	await get_tree().create_timer(crowd_reaction_duration).timeout
	continious_crowd_switch.set_value(self)

func _player_has_been_hit(player_id: int, damage: float, direction: Vector3):
	game_bar.shared_life_bar.add_damage_to_player(player_id, damage)
	camera_controller.trigger_hit_shake(direction, damage)
