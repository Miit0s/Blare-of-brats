extends GameScene

@export var input_reminders: Array[InputReminder]
@export var task_lists: Array[TaskList]
@export var task_prefab: PackedScene

var has_already_made_sound: bool = false

var _number_player_ready: int = 0
var _dash_quest_completed: bool = false
var _item_quest_completed: bool = false

func _ready() -> void:
	game_end_ui.to_main_menu_button_pressed.connect(go_to_next_scene)
	
	game_bar.player_win.connect(_on_shared_life_bar_player_win)
	game_bar.lifebar_value_change.connect(lifebar_value_change)
	
	players_win.resize(player_number)
	players_win.fill(0)
	
	round_state.set_value()
	
	game_bar.setup_color_and_texture(players_selection[0], players_selection[1])
	round_end_ui.change_player_data(players_selection[0], players_selection[1])
	
	input_reminders[0].player_input_id = players_selection[0].player_id
	input_reminders[1].player_input_id = players_selection[1].player_id
	
	for input_reminder in input_reminders:
		input_reminder.player_ready.connect(_player_his_ready)
	
	setup_new_scene()

func go_to_next_scene():
	pass

func _on_shared_life_bar_player_win(player_id: int) -> void:
	pass

func _item_made_sound(value: float, sound_global_position: Vector3):
	super._item_made_sound(value, sound_global_position)
	
	if not has_already_made_sound:
		has_already_made_sound = true
		_show_sound_bar()

func _player_his_ready():
	_number_player_ready += 1
	
	if player_number <= _number_player_ready:
		_trigger_dash_quest()

func _show_sound_bar():
	pass

func _trigger_dash_quest():
	camera_controller.start_tracking()
	
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
	pass

func _players_have_finish_quest():
	pass
