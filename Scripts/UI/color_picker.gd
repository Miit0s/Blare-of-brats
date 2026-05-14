extends Control
class_name CharacterColorPicker

@onready var color_options: ColorOptions = $ColorOptions

@export var color_options_for_skin: Dictionary[ControllerSlot.PossibleSkin, PackedScene]

func display_color_option_for_skin(skin: ControllerSlot.PossibleSkin):
	color_options.queue_free()
	color_options = color_options_for_skin[skin].instantiate()
	add_child(color_options)
