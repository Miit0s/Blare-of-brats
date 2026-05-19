extends Control
class_name CharacterColorPicker

@export var color_options_for_skin: Dictionary[ControllerSlot.PossibleSkin, ColorOptions]

var current_color_option: ColorOptions

func _ready() -> void:
	for option: ColorOptions in color_options_for_skin.values():
		option.hide()
	
	current_color_option = color_options_for_skin[ControllerSlot.PossibleSkin.MAX]

func display_color_option_for_skin(skin: ControllerSlot.PossibleSkin):
	current_color_option.hide()
	current_color_option = color_options_for_skin[skin]
	current_color_option.show()
