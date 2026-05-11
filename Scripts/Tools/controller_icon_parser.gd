@tool

extends RichTextLabel
class_name ControllerIconParser

@export var raw_text: String = "":
	set(new_value):
		raw_text = new_value
		if Engine.is_editor_hint(): text = new_value


func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	ControllerTypeManager.device_changed.connect(_update_display)
	_update_display(ControllerIconSet.PlatformName.XBOX)

func _update_display(_new_device_type: ControllerIconSet.PlatformName):
	var final_text = raw_text
	
	var regex_action = RegEx.new()
	regex_action.compile("\\{(.*?)\\}")
	
	var matches_action = regex_action.search_all(raw_text)
	for matche in matches_action:
		var action_name = matche.get_string(1)
		var path = ControllerTypeManager.get_icon_path_for_action(action_name)
		
		var img_tag = "[img=32x32]" + path + "[/img]"
		final_text = final_text.replace("{" + action_name + "}", img_tag)
	
	var regex_input = RegEx.new()
	regex_input.compile("\\#(.*?)\\#")
	
	var matches_input = regex_input.search_all(raw_text)
	for matche in matches_input:
		var action_name = matche.get_string(1)
		var path = ControllerTypeManager.get_icon_path_for_input(action_name)
		
		var img_tag = "[img=24x24]" + path + "[/img]"
		final_text = final_text.replace("{" + action_name + "}", img_tag)
	
	bbcode_enabled = true
	text = final_text
