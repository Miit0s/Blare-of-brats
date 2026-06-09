extends GameScene

@onready var show_sound_bar: Panel = $CanvasLayer/ShowSoundBar
@onready var show_life_bar: Panel = $CanvasLayer/ShowLifeBar
@onready var onboarding_text_display: OnboardingTextDisplay = $CanvasLayer/OnboardingTextDisplay

@export var input_reminders: Array[InputReminder]
@export var task_lists: Array[TaskList]
@export var task_prefab: PackedScene

@export_category("Text Tutorial")
@export var sound_title: String = "Sound Bar"
@export var sound_texts: Array[String]

@export var health_title: String = "Health Bar"
@export var health_texts: Array[String]

var has_already_made_sound: bool = false
var has_already_hit_player: bool = false

var _number_player_ready: int = 0
var _number_player_quest_complet: int = 0
var _dash_quest_completed: bool = false
var _item_quest_completed: bool = false

func _ready() -> void:
	game_end_ui.to_main_menu_button_pressed.connect(go_to_next_scene)
	onboarding_text_display.onboarding_text_display_finish.connect(onboarding_text_finish)
	
	game_bar.player_win.connect(_on_shared_life_bar_player_win)
	game_bar.lifebar_value_change.connect(lifebar_value_change)
	
	players_win.resize(player_number)
	players_win.fill(0)
	
	round_state.set_value()
	
	game_bar.setup_color_and_texture(players_selection[0], players_selection[1])
	round_end_ui.change_player_data(players_selection[0], players_selection[1])
	game_bar.shared_life_bar.lock()
	
	input_reminders[0].player_input_id = players_selection[0].player_id
	input_reminders[1].player_input_id = players_selection[1].player_id
	
	for input_reminder in input_reminders:
		input_reminder.player_ready.connect(_player_his_ready)
	
	for task_list in task_lists:
		task_list.all_task_complete.connect(_player_have_finish_quest)
	
	setup_new_scene()

func go_to_next_scene():
	var packed_game_scene: PackedScene = load(next_scene_uid)
	var game_scene: GameScene = packed_game_scene.instantiate()
	
	game_scene.players_selection.clear()
	for player_selection in players_selection:
		game_scene.players_selection.append(player_selection)
	
	get_tree().change_scene_to_node(game_scene)

func _on_shared_life_bar_player_win(player_id: int) -> void:
	var winner_data: PlayerCharacterSelection = _get_player_selection(player_id)
	
	camera_controller.stop_tracking()
	game_end_ui.show()
	game_end_ui.start_animation(player_id, winner_data.color_skin.main_color, players_selection[0].player_id)

func _item_made_sound(value: float, sound_global_position: Vector3):
	super._item_made_sound(value, sound_global_position)
	
	if not has_already_made_sound:
		has_already_made_sound = true
		_show_sound_bar()

func lifebar_value_change(lifebar_value: float):
	super.lifebar_value_change(lifebar_value)
	
	if not has_already_hit_player:
		has_already_hit_player = true
		_show_health_bar()

func _player_his_ready():
	_number_player_ready += 1
	
	if player_number <= _number_player_ready:
		camera_controller.start_tracking()
		_trigger_dash_quest()

func _show_sound_bar():
	show_sound_bar.show()
	game_bar.show()
	
	for player in players:
		player.freeze()
	
	onboarding_text_display.title.text = sound_title
	onboarding_text_display.add_texts_page(sound_texts)
	onboarding_text_display.show()

func _show_health_bar():
	show_life_bar.show()
	game_bar.show()
	
	for player in players:
		player.freeze()
	
	onboarding_text_display.title.text = health_title
	onboarding_text_display.add_texts_page(health_texts)
	onboarding_text_display.show()

func onboarding_text_finish():
	show_sound_bar.hide()
	show_life_bar.hide()
	onboarding_text_display.hide()
	onboarding_text_display.reset()
	
	for player in players:
		player.unfreeze()

func _trigger_dash_quest():
	for input_reminder in input_reminders:
		input_reminder.queue_free()
	
	for player in players:
		player.unfreeze()
	
	for i in task_lists.size():
		task_lists[i].show()
		
		var task: Task = task_prefab.instantiate()
		task.task_text.text = "Make a Dash"
		players[i].did_dash.connect(task.task_complete)
		
		task_lists[i].add_new_task(task)

func _trigger_item_quest():
	if _current_scene is MapOnboarding:
		_current_scene.move_down_wall()
	
	for i in task_lists.size():
		task_lists[i].clear_task()
		
		var pick_up_task: Task = task_prefab.instantiate()
		pick_up_task.task_text.text = "Pick up a object"
		players[i].pick_up_object.connect(pick_up_task.task_complete)
		
		var attack_task: Task = task_prefab.instantiate()
		attack_task.task_text.text = "Attack"
		players[i].did_attack.connect(attack_task.task_complete)
		
		var throw_task: Task = task_prefab.instantiate()
		throw_task.task_text.text = "Throw the object"
		players[i].did_throw.connect(throw_task.task_complete)
		
		task_lists[i].add_new_task(pick_up_task)
		task_lists[i].add_new_task(attack_task)
		task_lists[i].add_new_task(throw_task)

func _player_have_finish_quest():
	_number_player_quest_complet += 1
	if _number_player_quest_complet < player_number: return
	
	if not _dash_quest_completed:
		_dash_quest_completed = true
		_number_player_quest_complet = 0
		_trigger_item_quest()
	elif not _item_quest_completed:
		_item_quest_completed = true
		_number_player_quest_complet = 0
		game_bar.shared_life_bar.unlock()
		
		for task_list in task_lists:
			task_list.hide()
