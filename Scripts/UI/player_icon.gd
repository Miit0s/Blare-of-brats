extends Control
class_name PlayerIcon

@onready var texture_rect: TextureRect = $TextureRect

func apply_texture_and_color(shader_option: ShaderMaterial):
	texture_rect.texture = shader_option.get_shader_parameter("main_texture")
	texture_rect.material = shader_option
