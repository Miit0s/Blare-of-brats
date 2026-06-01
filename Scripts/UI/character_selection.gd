extends Control
class_name CharacterSelection

@onready var texture_rect: TextureRect = $TextureRect

var current_character_color: CharacterColorResource

func get_current_material() -> CharacterColorResource:
	return current_character_color

func apply_color_and_texture(color: CharacterColorResource = current_character_color, texture: Texture2D = texture_rect.texture):
	texture_rect.texture = texture
	texture_rect.material = color.color_shader_2d
	
	current_character_color = color
