extends Control

@onready var controller_slot_container: HBoxContainer = $ControllerSlotContainer

@export var max_player: int = 4
@export var controller_slot_prefab: PackedScene

var controller_slots: Array[ControllerSlot]

func _ready() -> void:
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	
	for controller_slot in controller_slot_container.get_children():
		controller_slots.append(controller_slot)

func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton:
		if event.is_action_pressed("JoinGame"):
			if is_device_already_connected(event.device):
				get_controller_slot_for_device(event.device).player_is_holding_ready_key = true
			else:
				connect_controller_to_slot(event.device)
				get_viewport().set_input_as_handled()
		
		if event.is_action_pressed("Return") and is_device_already_connected(event.device):
			remove_controller_slot(event.device)
		
		if event.is_action_released("JoinGame"):
			if is_device_already_connected(event.device):
				get_controller_slot_for_device(event.device).player_is_holding_ready_key = false

func connect_controller_to_slot(device_id: int):
	pick_existing_slot(device_id)
	
	if controller_slots.size() < max_player and is_all_slot_pick():
		add_controller_slot()

## Return true if a existing slot have been found, false else.
func pick_existing_slot(device_id: int) -> bool:
	for i in controller_slots.size():
		
		if controller_slots[i].is_slot_available:
			controller_slots[i].set_player_id(device_id)
			return true
	
	return false

func add_controller_slot():
	if controller_slots.size() >= max_player: return
	
	var controller_slot_instance: ControllerSlot = controller_slot_prefab.instantiate()
	controller_slots.append(controller_slot_instance)
	controller_slot_container.add_child(controller_slot_instance)

func remove_controller_slot(device_id: int):
	for i in controller_slots.size():
		if controller_slots[i].get_player_id() == device_id:
			if  controller_slots.size() == 3:
				remove_first_empty_slot()
				controller_slots[i].remove_player()
				return
			elif controller_slots.size() <= 2:
				controller_slots[i].remove_player()
				return
			else:
				var controller_slot: ControllerSlot = controller_slots.pop_at(i)
				controller_slot_container.remove_child(controller_slot)
				return

func get_controller_slot_for_device(device_id: int) -> ControllerSlot:
	for controller in controller_slots:
		if controller.get_player_id() == device_id: return controller
	return null

func remove_first_empty_slot():
	for i in controller_slots.size():
		if controller_slots[i].is_slot_available:
			var controller_slot: ControllerSlot = controller_slots.pop_at(i)
			controller_slot_container.remove_child(controller_slot)
			return

func is_device_already_connected(device_id: int) -> bool:
	for slot in controller_slots:
		if slot.get_player_id() == device_id: return true
	
	return false

func is_all_slot_pick() -> bool:
	for controller_slot: ControllerSlot in controller_slots:
		if controller_slot.is_slot_available: return false
	
	return true

func _on_joy_connection_changed(device: int, connected: bool):
	if not connected:
		remove_controller_slot(device)
