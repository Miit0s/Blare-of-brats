extends Control

@onready var controller_slot_container: HBoxContainer = $ControllerSlotContainer
@onready var return_radial_progress_bar: RadialProgressBarWithText = $ReturnRadialProgressBar

@export var max_player: int = 4
@export var controller_slot_prefab: PackedScene

@export var main_menu_scene_uid: String
@export var game_scene_uid: String

var controller_slots: Array[ControllerSlot]

var _player_ready: int = 0

func _ready() -> void:
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	
	for controller_slot in controller_slot_container.get_children():
		controller_slots.append(controller_slot)

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

func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton:
		if event.is_action_pressed("JoinGame"):
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
			get_viewport().set_input_as_handled()
			return
		
		if event.is_action_pressed("Return") and not is_device_already_connected(event.device):
			return_radial_progress_bar.player_start_holding_key()
			get_viewport().set_input_as_handled()
			return
		elif event.is_action_released("Return") and not is_device_already_connected(event.device):
			return_radial_progress_bar.player_stop_holding_key()
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
	get_tree().change_scene_to_file(game_scene_uid)

func _on_joy_connection_changed(device: int, connected: bool):
	if not connected:
		remove_controller_slot(device)

func _on_controller_slot_player_his_ready() -> void:
	_player_ready += 1
	
	if _player_ready >= controller_slots.size():
		start_game()


func _on_controller_slot_player_no_more_ready() -> void:
	_player_ready -= 1


func _on_return_radial_progress_bar_hold_finish() -> void:
	get_tree().change_scene_to_file(main_menu_scene_uid)
