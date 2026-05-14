extends Control
class_name SelectedPlayerUI

@onready var texture_rect: TextureRect = $TextureRect

@onready var up_arrow: TextureRect = $UpArrow
@onready var down_arrow: TextureRect = $DownArrow

@onready var left_arrow: TextureRect = $LeftArrow
@onready var right_arrow: TextureRect = $RightArrow

@onready var color_picker: CharacterColorPicker = $ColorPicker
@onready var ready_state: Control = $ReadyState

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

func set_new_character(texture: Texture2D, shader_material: ShaderMaterial, skin: ControllerSlot.PossibleSkin):
	texture_rect.texture = texture
	texture_rect.material = shader_material
	color_picker.display_color_option_for_skin(skin)

func apply_next_color():
	var shader_material: ShaderMaterial =  color_picker.color_options.get_and_select_next_color()
	
	if shader_material:
		texture_rect.material = shader_material

func apply_previous_color():
	var shader_material: ShaderMaterial =  color_picker.color_options.get_and_select_previous_color()
	
	if shader_material:
		texture_rect.material = shader_material
