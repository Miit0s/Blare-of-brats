extends Node

signal device_changed(device_type: ControllerIconSet.PlatformName)

var current_device: ControllerIconSet.PlatformName
var icon_sets: Dictionary = {
	ControllerIconSet.PlatformName.PLAYSTATION: preload("uid://bc17i7ioqxosn"),
	ControllerIconSet.PlatformName.XBOX: preload("uid://br26gdxuc7iu4"),
	ControllerIconSet.PlatformName.STEAM: preload("uid://civbv4rh0yifp"),
	ControllerIconSet.PlatformName.NINTENDO: preload("uid://ce577jeai8fsd")
}

func _input(event: InputEvent) -> void:
	var new_device: ControllerIconSet.PlatformName = current_device
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		var device_name: String = Input.get_joy_name(event.device).to_lower()
		
		if "ps5" in device_name or "dualsense" in device_name:
			new_device = ControllerIconSet.PlatformName.PLAYSTATION
		elif "xbox" in device_name:
			new_device = ControllerIconSet.PlatformName.XBOX
		elif "steam" in device_name:
			new_device = ControllerIconSet.PlatformName.STEAM
		elif "switch" in device_name:
			new_device = ControllerIconSet.PlatformName.NINTENDO
		else:
			new_device = ControllerIconSet.PlatformName.XBOX
	
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
