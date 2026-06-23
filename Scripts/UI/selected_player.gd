extends CharacterSelection
class_name MainCharacterSelection

@onready var up_arrow: TextureRect = $UpArrow
@onready var down_arrow: TextureRect = $DownArrow

@onready var left_arrow: TextureRect = $LeftArrow
@onready var right_arrow: TextureRect = $RightArrow

@onready var color_picker: CharacterColorPicker = $ColorPicker
@onready var ready_state: Control = $ReadyState

@export_category("SFX")
@export var color_select_sound : WwiseEvent

func _ready() -> void:
	set_character_selection_state()

func set_character_selection_state():
	up_arrow.hide()
	down_arrow.hide()
	
	color_picker.hide()
	ready_state.hide()
	
	left_arrow.show()
	right_arrow.show()

func set_character_color_selection_state():
	left_arrow.hide()
	right_arrow.hide()
	
	ready_state.hide()
	
	up_arrow.show()
	down_arrow.show()
	
	color_picker.show()

func set_ready_state():
	up_arrow.hide()
	down_arrow.hide()
	
	left_arrow.hide()
	right_arrow.hide()
	
	color_picker.hide()
	
	ready_state.show()

func set_new_character(texture: Texture2D, character_color: CharacterColorResource, skin: ControllerSlot.PossibleSkin, no_sound: bool = false):
	apply_color_and_texture(character_color, texture)
	color_picker.display_color_option_for_skin(skin)
	
	if not no_sound:
		color_select_sound.post(self)

## Return if the apply was a success
func apply_next_color() -> bool:
	var new_character_color = color_picker.current_color_option.get_and_select_next_color()
	
	if new_character_color:
		apply_color_and_texture(new_character_color)
		color_select_sound.post(self)
		return true
	return false

## Return if the apply was a success
func apply_previous_color():
	var new_character_color = color_picker.current_color_option.get_and_select_previous_color()
	
	if new_character_color:
		apply_color_and_texture(new_character_color)
		color_select_sound.post(self)
		return true
	return false

func lock_color(color: CharacterColorResource):
	color_picker.lock_color(color)

func unlock_color(color: CharacterColorResource):
	color_picker.unlock_color(color)
