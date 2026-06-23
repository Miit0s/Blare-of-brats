extends Control

@onready var controller_slot_container: Control = $ControllerSlotContainer
@onready var return_radial_progress_bar: RadialProgressBarWithText = $TextureRect/HBoxContainer/ReturnRadialProgressBar

@onready var ready_screen: SubViewportContainer = $ReadyScreen
@onready var radial_progress_bar_with_text: RadialProgressBarWithText = $ReadyScreen/SubViewport/ReadyTexture/TextureRect/HBoxContainer/RadialProgressBarWithText

@onready var stand_1: TextureRect = $Visual/Stand1
@onready var stand_2: TextureRect = $Visual/Stand2
@onready var light_stand_1: TextureRect = $Visual/Stand1/LightStand1
@onready var light_stand_2: TextureRect = $Visual/Stand2/LightStand2

@export var max_player: int = 4
@export var controller_slot_prefab: PackedScene

@export var main_menu_scene_uid: String
@export var game_scene_uid: String
@export var onboarding_scene_uid: String

@export var stage_empty: Texture2D
@export var stage_skin_pick: Texture2D
@export var stage_color_pick: Texture2D
@export var stage_ready: Texture2D

@export_category("Tween")
@export var ready_tween_transition_duration: float = 0.5

@export_category("Vibration")
@export_group("On Game Start")
@export_range(0, 1) var vibration_force_on_game_start: float = 1.0
@export var vibration_duration_on_game_start: float = 1.0

@export_group("On Interaction")
@export_range(0, 1) var vibration_force_on_interaction: float = 0.1
@export var vibration_duration_on_interaction: float = 0.1

@export_group("On Return to main menu")
@export_range(0, 1) var vibration_force_on_return: float = 1.0

@export_category("Sound")
@export var music_sound: WwiseEvent
@export var player_pick_state: WwiseState
@export var ready_screen_state: WwiseState

var controller_slots: Array[ControllerSlot]

var _player_ready: int = 0
var _device_returning: int = -1

var is_loading_transtion_finish: bool = false
var is_ready_screen_transition_finish: bool = true

var _is_ready_texture_display: bool = false

func _ready() -> void:
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	
	music_sound.post(self)
	player_pick_state.set_value()

	for controller_slot: ControllerSlot in controller_slot_container.get_children():
		controller_slot.player_his_ready.connect(_on_controller_slot_player_his_ready)
		controller_slot.player_no_more_ready.connect(_on_controller_slot_player_no_more_ready)
		controller_slot.has_change_state.connect(_on_controller_slot_state_change)
		controller_slots.append(controller_slot)
	
	LoadingPage.despawn_transtion()
	await LoadingPage.transition_finish
	
	is_loading_transtion_finish = true

func _process(_delta: float) -> void:
	for i in max_player:
		var suffix: String = "_" + str(i)
		if (Input.is_action_just_pressed("NextCharacter" + suffix) or \
			Input.is_action_just_pressed("PreviousCharacter" + suffix)) and \
			is_device_already_connected(i):
				var player_slot: ControllerSlot = get_controller_slot_for_device(i)
				if player_slot.current_state == ControllerSlot.SelectionState.CHARACTER_SELECTION:
					player_slot.swap_character_texture()
			
		if Input.is_action_just_pressed("NextColor" + suffix) and is_device_already_connected(i):
			var player_slot: ControllerSlot = get_controller_slot_for_device(i)
			if player_slot.current_state == ControllerSlot.SelectionState.COLOR_SELECTION:
				player_slot.next_character_color()
		elif Input.is_action_just_pressed("PreviousColor" + suffix) and is_device_already_connected(i):
			var player_slot: ControllerSlot = get_controller_slot_for_device(i)
			if player_slot.current_state == ControllerSlot.SelectionState.COLOR_SELECTION:
				player_slot.previous_character_color()
	
	if _is_ready_texture_display and Input.is_action_just_pressed("JoinGame"):
		radial_progress_bar_with_text.player_start_holding_key()
	if _is_ready_texture_display and Input.is_action_just_released("JoinGame"):
		radial_progress_bar_with_text.player_stop_holding_key()

func _input(event: InputEvent) -> void:
	if not is_loading_transtion_finish: return
	if not is_ready_screen_transition_finish: return
	
	if event is InputEventJoypadButton:
		if event.is_action_pressed("JoinGame"):
			VibrationManager.start_joy_vibration(event.device, vibration_force_on_interaction, 0 , vibration_duration_on_interaction)
			if is_device_already_connected(event.device):
				get_controller_slot_for_device(event.device).next_state(event.device)
				get_viewport().set_input_as_handled()
				return
			else:
				connect_controller_to_slot(event.device)
				get_viewport().set_input_as_handled()
				return
		
		if event.is_action_pressed("Return") and is_device_already_connected(event.device):
			get_controller_slot_for_device(event.device).back(event.device)
			VibrationManager.start_joy_vibration(event.device, vibration_force_on_interaction, 0 , vibration_duration_on_interaction)
			get_viewport().set_input_as_handled()
			return
		
		if event.is_action_pressed("Return") and not is_device_already_connected(event.device):
			return_radial_progress_bar.player_start_holding_key()
			_device_returning = event.device
			VibrationManager.start_joy_vibration(event.device, vibration_force_on_return, 0 )
			get_viewport().set_input_as_handled()
			return
		elif event.is_action_released("Return") and not is_device_already_connected(event.device):
			return_radial_progress_bar.player_stop_holding_key()
			_device_returning = -1
			VibrationManager.stop_joy_vibration(event.device)
			get_viewport().set_input_as_handled()
			return

func connect_controller_to_slot(device_id: int):
	pick_existing_slot(device_id)
	
	if controller_slots.size() < max_player and is_all_slot_pick():
		add_controller_slot()

## Return true if a existing slot have been found, false else.
func pick_existing_slot(device_id: int) -> bool:
	for i in controller_slots.size():
		
		if controller_slots[i].is_slot_available:
			controller_slots[i].next_state(device_id)
			return true
	
	return false

func add_controller_slot():
	if controller_slots.size() >= max_player: return
	
	var controller_slot_instance: ControllerSlot = controller_slot_prefab.instantiate()
	controller_slots.append(controller_slot_instance)
	controller_slot_container.add_child(controller_slot_instance)
	controller_slot_instance.player_his_ready.connect(_on_controller_slot_player_his_ready)
	controller_slot_instance.player_no_more_ready.connect(_on_controller_slot_player_no_more_ready)

func remove_controller_slot(device_id: int):
	for i in controller_slots.size():
		if controller_slots[i].get_player_id() == device_id:
			if  controller_slots.size() == 3:
				remove_first_empty_slot()
				controller_slots[i].switch_to_empty_slot()
				return
			elif controller_slots.size() <= 2:
				controller_slots[i].switch_to_empty_slot()
				return
			else:
				var controller_slot: ControllerSlot = controller_slots.pop_at(i)
				remove_slot(controller_slot)
				return

func get_controller_slot_for_device(device_id: int) -> ControllerSlot:
	for controller in controller_slots:
		if controller.get_player_id() == device_id: return controller
	return null

func remove_first_empty_slot():
	for i in controller_slots.size():
		if controller_slots[i].is_slot_available:
			var controller_slot: ControllerSlot = controller_slots.pop_at(i)
			remove_slot(controller_slot)
			return

func remove_slot(controller_slot: ControllerSlot):
	controller_slot.player_his_ready.disconnect(_on_controller_slot_player_his_ready)
	controller_slot.player_no_more_ready.disconnect(_on_controller_slot_player_no_more_ready)
	controller_slot_container.remove_child(controller_slot)

func is_device_already_connected(device_id: int) -> bool:
	for slot in controller_slots:
		if slot.get_player_id() == device_id: return true
	
	return false

func is_all_slot_pick() -> bool:
	for controller_slot: ControllerSlot in controller_slots:
		if controller_slot.is_slot_available: return false
	
	return true

func start_game():
	music_sound.stop(self)

	for controller_slot in controller_slots:
		VibrationManager.start_joy_vibration(controller_slot.get_player_id(), vibration_force_on_game_start, vibration_force_on_game_start / 2, vibration_duration_on_game_start)
	
	LoadingPage.packed_scene_loaded.connect(_setup_game_scene_and_change, ConnectFlags.CONNECT_ONE_SHOT)
	if GameOptions.have_played_tutorial and not GameOptions.saved_options.activate_on_boarding:
		LoadingPage.start_transtion_to_scene(game_scene_uid)
	else:
		LoadingPage.start_transtion_to_scene(onboarding_scene_uid)

func _setup_game_scene_and_change(packed_game_scene: PackedScene):
	var game_scene: GameScene = packed_game_scene.instantiate()
	
	game_scene.players_selection.clear()
	for controller_slot in controller_slots:
		game_scene.players_selection.append(controller_slot.get_player_selection())
	
	get_tree().change_scene_to_node(game_scene)

func _on_joy_connection_changed(device: int, connected: bool):
	if not connected:
		remove_controller_slot(device)

func _on_controller_slot_player_his_ready(controller_slot: ControllerSlot) -> void:
	_player_ready += 1
	
	_lock_color_for_all(controller_slot.get_player_selection().color_skin)
	
	if _player_ready >= controller_slots.size():
		is_ready_screen_transition_finish = false
		
		var shader: ShaderMaterial = ready_screen.material
		shader.set_shader_parameter("invert", true)
		shader.set_shader_parameter("progress", 0.0)
		
		ready_screen.show()
		
		var spawn_transition: Tween = create_tween()
		spawn_transition.set_ease(Tween.EASE_OUT)
		spawn_transition.set_trans(Tween.TRANS_QUAD)
		spawn_transition.tween_method(_update_ready_screen_transtion_progress_value, 0.0, 3.8, ready_tween_transition_duration)
		
		await spawn_transition.finished
		
		_is_ready_texture_display = true
		is_ready_screen_transition_finish = true
		
		ready_screen_state.set_value()


func _on_controller_slot_state_change(controller_slot_id: int, new_state: ControllerSlot.SelectionState):
	var stand: TextureRect = stand_1 if controller_slot_id == 0 else stand_2
	var stand_light: TextureRect = light_stand_1 if controller_slot_id == 0 else light_stand_2
	
	match new_state:
		ControllerSlot.SelectionState.EMPTY: stand.texture = stage_empty
		ControllerSlot.SelectionState.CHARACTER_SELECTION: stand.texture = stage_skin_pick
		ControllerSlot.SelectionState.COLOR_SELECTION: 
			stand.texture = stage_color_pick
			stand_light.hide()
		ControllerSlot.SelectionState.READY: 
			stand.texture = stage_ready
			stand_light.show()


func _on_controller_slot_player_no_more_ready(controller_slot: ControllerSlot) -> void:
	_player_ready -= 1
	
	_unlock_color_for_all(controller_slot.get_player_selection().color_skin)
	
	if _is_ready_texture_display:
		is_ready_screen_transition_finish = false
		_is_ready_texture_display = false
		
		var shader: ShaderMaterial = ready_screen.material
		shader.set_shader_parameter("invert", false)
		shader.set_shader_parameter("progress", 0.0)
		
		var despawn_transition: Tween = create_tween()
		despawn_transition.set_ease(Tween.EASE_OUT)
		despawn_transition.set_trans(Tween.TRANS_QUAD)
		despawn_transition.tween_method(_update_ready_screen_transtion_progress_value, 0.0, 3.8, ready_tween_transition_duration)
		
		await despawn_transition.finished
		
		ready_screen.hide()
		is_ready_screen_transition_finish = true
		
		player_pick_state.set_value()

func _update_ready_screen_transtion_progress_value(value: float):
	var shader: ShaderMaterial = ready_screen.material
	shader.set_shader_parameter("progress", value)


func _on_return_radial_progress_bar_hold_finish() -> void:
	VibrationManager.stop_joy_vibration(_device_returning)
	
	LoadingPage.packed_scene_loaded.connect(get_tree().change_scene_to_packed, ConnectFlags.CONNECT_ONE_SHOT)
	LoadingPage.start_transtion_to_scene(main_menu_scene_uid)

func _lock_color_for_all(color: CharacterColorResource):
	for controller_slot in controller_slots:
		controller_slot.lock_color(color)

func _unlock_color_for_all(color: CharacterColorResource):
	for controller_slot in controller_slots:
		controller_slot.unlock_color(color)
