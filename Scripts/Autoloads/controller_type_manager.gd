extends Node

var device_cache: Dictionary = {}

var current_device: ControllerIconSet.PlatformName
var icon_sets: Dictionary = {
	ControllerIconSet.PlatformName.PLAYSTATION: preload("uid://bc17i7ioqxosn"),
	ControllerIconSet.PlatformName.XBOX: preload("uid://br26gdxuc7iu4"),
	ControllerIconSet.PlatformName.STEAM: preload("uid://civbv4rh0yifp"),
	ControllerIconSet.PlatformName.NINTENDO: preload("uid://ce577jeai8fsd")
}

signal device_changed(device_type: ControllerIconSet.PlatformName)

func _ready() -> void:
	Input.joy_connection_changed.connect(_on_joy_connection_changed)

func _on_joy_connection_changed(device_id: int, connected: bool):
	if connected:
		device_cache[device_id] = _get_controller_plateform_from_id(device_id)
	else:
		device_cache.erase(device_id)

func _get_controller_plateform_from_id(device_id: int) -> ControllerIconSet.PlatformName:
	var new_device: ControllerIconSet.PlatformName = current_device
	var device_name: String = Input.get_joy_name(device_id).to_lower()
	
	if "ps5" in device_name or "dualsense" in device_name:
		new_device = ControllerIconSet.PlatformName.PLAYSTATION
	elif "xbox" in device_name or "xinput" in device_name:
		new_device = ControllerIconSet.PlatformName.XBOX
	elif "steam" in device_name:
		new_device = ControllerIconSet.PlatformName.STEAM
	elif "switch" in device_name:
		new_device = ControllerIconSet.PlatformName.NINTENDO
	else:
		new_device = ControllerIconSet.PlatformName.XBOX
	
	return new_device

func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		var new_device = device_cache.get(event.device, ControllerIconSet.PlatformName.XBOX)
	
		if new_device != current_device:
			current_device = new_device
			device_changed.emit(current_device)

func get_icon_path_for_action(action_name: String) -> String:
	var event: InputEvent = InputMap.action_get_events(action_name)[0]
	
	var icon: Texture2D = icon_sets[current_device].get_icon_for_joybutton(event.button_index)
	return icon.resource_path

func get_icon_path_for_input(input_name: JoyButton) -> String:
	var icon: Texture2D = icon_sets[current_device].get_icon_for_joybutton(input_name)
	return icon.resource_path
