extends Control

@onready var controller_slot_container: HBoxContainer = $ControllerSlotContainer

@export var max_player: int = 4
@export var controller_slot_prefab: PackedScene

var controller_slots: Array[ControllerSlot]

func _ready() -> void:
	Input.joy_connection_changed.connect(_on_joy_connection_changed)

func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton and event.is_action_pressed("JoinGame"):
		
		if is_device_already_connected(event.device): return
		
		add_controller_slot(event.device)
		get_viewport().set_input_as_handled()

func add_controller_slot(device_id: int):
	if controller_slot_container.get_children().size() >= max_player: return
	
	var controller_slot_instance: ControllerSlot = controller_slot_prefab.instantiate()
	controller_slots.append(controller_slot_instance)
	controller_slot_container.add_child(controller_slot_instance)
	
	controller_slot_instance.set_player_id(device_id)

func remove_controller_slot(device_id: int):
	if controller_slot_container.get_children().size() <= 2: return
	
	for i in controller_slots.size():
		if controller_slots[i].get_player_id() == device_id:
			controller_slots.remove_at(i)
			return

func is_device_already_connected(device_id: int) -> bool:
	for slot in controller_slots:
		if slot.get_player_id() == device_id: return true
	
	return false

func _on_joy_connection_changed(device: int, connected: bool):
	print("Controller connected or disconnected")
	
	if connected:
		add_controller_slot(device)
	else:
		remove_controller_slot(device)
