extends Control
class_name SideEndScreen

@export var node_to_color: Array[Control]
@export var player: TextureRect
@export var is_winning_scene: bool = false

func apply_color(chara_color: CharacterColorResource):
	for node in node_to_color:
		node.self_modulate = chara_color.main_color
	
	var shader_material: ShaderMaterial = chara_color.color_shader_winning if is_winning_scene else chara_color.color_shader_loosing
	
	player.texture = shader_material.get_shader_parameter("main_texture")
	player.material = shader_material
