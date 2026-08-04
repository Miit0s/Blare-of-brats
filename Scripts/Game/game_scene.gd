extends Node3D
class_name GameScene

@onready var round_start_ui: RoundStartUI = $CanvasLayer/RoundStart
@onready var round_end_ui: RoundEnd = $CanvasLayer/RoundEnd
@onready var game_end_ui: GameEnd = $CanvasLayer/GameEnd

@export_category("Instance")
@export var game_bar: GameBar
@export var camera_controller: CameraController
@export var next_scene_uid: String
@export var restart_game_scene_uid: String

@export var tracking_spot_player_one: TrackingSpot
@export var tracking_spot_player_two: TrackingSpot

@export_category("PartySetup")
@export var player_number: int = 2
@export var round_number: int = 3

@export_category("Sound")
@export var countdown: WwiseEvent
@export var lead: WwiseRTPC
@export_group("Soundbar related sound")
@export var soundbar_lvl1: WwiseEvent
@export var soundbar_lvl2: WwiseEvent
@export var bar_volume_rtpc: WwiseRTPC
@export_group("Crowd")
@export var crowd_reaction_duration: float = 1.5
@export var crowd_sound : WwiseEvent
@export var continious_crowd_switch: WwiseSwitch
@export var reaction_crowd_switch: WwiseSwitch
@export var danger_phase_crowd_switch: WwiseSwitch

@export_category("Vibration")
@export_group("Round Begin")
@export_range(0, 1) var round_begin_vibration_force: float = 0.5
@export var round_begin_vibration_duration: float = 0.2

@export_group("Round End")
@export_range(0, 1) var round_end_vibration_force: float = 0.5
@export var round_end_vibration_duration: float = 0.5

@export_category("Level")
@export var possible_level: Array[PackedScene]

@export_category("Danger Phase")
@export var wait_duration_after_cutscene_end_to_trigger_wolf: float = 0.5

var players: Array[Player]
var player_stats: Dictionary[int, EndGameResource]
var _last_player_win_id: int = -1

var players_selection: Array[PlayerCharacterSelection] = [preload("uid://4w1f5mgj2e5s"), preload("uid://cligadeo7a6fk")]

var _current_scene: MapScene
var _round_ended: bool = false
var _first_round_setup: bool = true
var _have_see_wolf_cutscene_is_this_game: bool = false

var _crow_reaction_wait_tween: Tween = null

func _ready() -> void:
	round_start_ui.start_round.connect(start_round)
	round_start_ui.animation_finish.connect(round_start_ui.hide)
	round_end_ui.next_round_button_pressed.connect(start_round_animation)
	game_end_ui.to_main_menu_button_pressed.connect(go_to_next_scene, ConnectFlags.CONNECT_ONE_SHOT)
	game_end_ui.restart_button_pressed.connect(restart_new_game, ConnectFlags.CONNECT_ONE_SHOT)
	
	game_bar.player_win.connect(_on_shared_life_bar_player_win)
	game_bar.sound_bar_fill.connect(_on_game_sound_bar_sound_bar_fill)
	game_bar.lifebar_value_change.connect(lifebar_value_change)
	game_bar.shared_life_bar.player_have_reach_min_life.connect(_trigger_crowd_reaction)
	game_bar.lock_area_pass.connect(_on_soundbar_lock_area_pass)
	
	for player_selection: PlayerCharacterSelection in players_selection:
		var end_game_resource: EndGameResource = EndGameResource.new()
		end_game_resource.character_color = player_selection.color_skin
		
		player_stats[player_selection.player_id] = end_game_resource
	
	setup_new_scene()
	
	LoadingPage.despawn_transtion()
	await LoadingPage.transition_finish
	
	start_round_animation()

func _process(_delta: float) -> void:
	bar_volume_rtpc.set_value(self, game_bar.game_sound_bar._game_sound_bar_volume * 100)

func start_round_animation():
	if round_end_ui.visible:
		round_end_ui.hide_animation()
		await round_end_ui.animation_finish
	
	countdown.post(self)
	
	game_bar.setup_color_and_texture(players_selection[0], players_selection[1])
	
	if _first_round_setup:
		_first_round_setup = false
	else:
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
	
	MainMusicManager.set_phase_1_state()
	crowd_sound.post(self)
	
	
	# Victor ici
	var v_gauche = game_bar.round_win_indicator_left.round_win
	var v_droite = game_bar.round_win_indicator_right.round_win
	var round_number = v_gauche + v_droite + 1
	
	TelemetryManager.preparer_fichier(round_number)
	
	TelemetryManager.temps_debut_round = Time.get_ticks_msec()
	
	TelemetryManager.game_timer.start()

func setup_new_scene():
	if _current_scene:
		_current_scene.queue_free()
	
	players.clear()
	
	var new_scene: MapScene = possible_level.pick_random().instantiate()
	TelemetryManager.get_scene(new_scene)
	new_scene.item_will_be_delete.connect(_on_map_item_will_be_delete)
	new_scene.new_item_spawn.connect(_on_map_new_item_spawn)
	new_scene.new_player_spawn.connect(_on_map_new_player_spawn)
	new_scene.balloon_pop.connect(_item_made_sound)
	new_scene.balloon_pop_by.connect(_player_have_made_sound)
	new_scene.balloon_pop_by.connect(func(player_id: int, _value: float): _player_have_pop_ballon(player_id))
	
	new_scene.player_spawn_system.spawn_players(players_selection)
	
	new_scene.wolf_has_hit_player.connect(camera_controller.trigger_wolf_stun_shake)
	
	_current_scene = new_scene
	
	add_child(new_scene)

func round_end_animaion_finish():
	game_bar.add_player_win(_last_player_win_id)
	
	if _check_if_game_end():
		player_stats[_last_player_win_id].is_winner = true
		
		await get_tree().create_timer(1.0).timeout
		
		round_end_ui.hide()
		game_end_ui.show()
		game_end_ui.setup_scene_and_start_animation(player_stats[players[0].player_id], player_stats[players[1].player_id])
	else:
		round_end_ui.show_next_round_button()

func player_win(player_id: int):
	if _round_ended: return
	
	TelemetryManager.game_timer.stop()
	print("Fin du round ")
	
	_round_ended = true
	player_stats[player_id].score += 1
	_last_player_win_id = player_id
	
	game_bar.hide()
	game_bar.shared_life_bar.lock()
	
	var players_win_array: Array[int] = [player_stats[players[0].player_id].score, player_stats[players[1].player_id].score]
	
	_current_scene.base_map.stop_wolf_light()
	
	for player in players:
		player.reset_vibration()
		VibrationManager.start_joy_vibration(player.player_id, round_end_vibration_force, 0, round_end_vibration_duration)
		player.freeze()
	
	camera_controller.stop_tracking()
	tracking_spot_player_one.target = null
	tracking_spot_player_two.target = null
	
	MainMusicManager.set_sound_stop_state()
	
	round_end_ui.animation_finish.connect(round_end_animaion_finish, ConnectFlags.CONNECT_ONE_SHOT)
	round_end_ui.show()
	round_end_ui.start_animation(players_win_array, _get_player_selection(player_id).color_skin)

func go_to_next_scene():
	crowd_sound.stop(self)
	
	LoadingPage.packed_scene_loaded.connect(get_tree().change_scene_to_packed, ConnectFlags.CONNECT_ONE_SHOT)
	LoadingPage.start_transtion_to_scene(next_scene_uid)

func restart_new_game():
	crowd_sound.stop(self)
	
	LoadingPage.packed_scene_loaded.connect(_setup_game_scene_with_parameters, ConnectFlags.CONNECT_ONE_SHOT)
	LoadingPage.start_transtion_to_scene(restart_game_scene_uid)

func _setup_game_scene_with_parameters(packed_game_scene: PackedScene):
	var game_scene: GameScene = packed_game_scene.instantiate()
	
	game_scene.players_selection.clear()
	for player_selection in players_selection:
		game_scene.players_selection.append(player_selection)
	
	get_tree().change_scene_to_node(game_scene)

func _on_shared_life_bar_player_win(player_id: int) -> void:
	player_win(player_id)


func _on_game_sound_bar_sound_bar_fill() -> void:
	_activate_the_danger_phase()


func lifebar_value_change(lifebar_value: float):
	lead.set_value(self, lifebar_value * 100)


func _on_map_item_will_be_delete(item: Item) -> void:
	item.sound_made.disconnect(_item_made_sound)
	item.sound_made_by.disconnect(_player_have_made_sound)
	item.item_broke_by.disconnect(_player_have_broke_his_item)
	camera_controller.trigger_objet_destruction_shake()


func _on_map_new_item_spawn(new_item: Item) -> void:
	new_item.sound_made.connect(_item_made_sound)
	new_item.sound_made_by.connect(_player_have_made_sound)
	new_item.item_broke_by.connect(_player_have_broke_his_item)


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
	var players_score: Array[int]
	var rounds_played: int = 0
	for player_stat: EndGameResource in player_stats.values(): 
		rounds_played += player_stat.score
		players_score.append(player_stat.score)
	
	var missing_round = round_number - rounds_played
	
	var players_win_sorted: Array[int] = players_score.duplicate()
	players_win_sorted.sort_custom(func(a, b): return a > b)
	
	if (players_win_sorted[0] - players_win_sorted[1]) > missing_round: return true
	if missing_round <= 0: return true
	
	return false

func _get_player_selection(player_id: int) -> PlayerCharacterSelection:
	if players_selection[0].player_id == player_id:
		return players_selection[0]
	return players_selection[1]

func _activate_the_danger_phase():
	var controller_id: Array[int] = []
	for player in players:
		controller_id.append(player.player_id)
	
	_current_scene.activate_danger_phase(!_have_see_wolf_cutscene_is_this_game, controller_id)
	
	MainMusicManager.set_phase_danger_state()
	danger_phase_crowd_switch.set_value(self)
	
	if not _have_see_wolf_cutscene_is_this_game:
		for player in players:
			player.freeze()
		game_bar.hide()
		
		await _current_scene.wolf_cutscene_finish
		
		_have_see_wolf_cutscene_is_this_game = true
		
		for player in players:
			player.unfreeze()
		game_bar.show()
		
		await get_tree().create_timer(wait_duration_after_cutscene_end_to_trigger_wolf).timeout
	else:
		await _current_scene.wolf_cutscene_finish
	
	_current_scene.activate_wolf_tracking_spot()
	game_bar.change_sound_bar_color(Color(1.0, 0.0, 0.0, 1.0))

func _on_soundbar_lock_area_pass(lock_phase: int):
	match lock_phase:
		0: 
			MainMusicManager.set_phase_1_state()
		1: 
			MainMusicManager.set_phase_2_state()
			soundbar_lvl1.post(self)
		2: 
			MainMusicManager.set_phase_3_state()
			soundbar_lvl2.post(self)

func _trigger_crowd_reaction():
	if _crow_reaction_wait_tween:
		_crow_reaction_wait_tween.kill()
		_crow_reaction_wait_tween = null
	
	_crow_reaction_wait_tween = create_tween()
	_crow_reaction_wait_tween.tween_callback(reaction_crowd_switch.set_value.bind(self))
	_crow_reaction_wait_tween.tween_interval(crowd_reaction_duration)
	_crow_reaction_wait_tween.tween_callback(continious_crowd_switch.set_value.bind(self))
	_crow_reaction_wait_tween.tween_callback(func(): _crow_reaction_wait_tween = null)

func _player_has_been_hit(player_id: int, damage: float, direction: Vector3):
	var reverse_id: int = 0 if player_id == 1 else 1
	player_stats[reverse_id].damage += damage
	
	game_bar.shared_life_bar.add_damage_to_player(player_id, damage)
	camera_controller.trigger_hit_shake(direction, damage)

func _player_have_broke_his_item(player_id: int):
	player_stats[player_id].item_broken += 1

func _player_have_pop_ballon(player_id: int):
	player_stats[player_id].ballon_popped += 1

func _player_have_made_sound(player_id: int, value: float):
	player_stats[player_id].noise_made += value
