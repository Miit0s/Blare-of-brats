extends Control
class_name RoundWinIndicator

@onready var texture_rect: TextureRect = $TextureRect

var round_win: int = 0

func new_round_win():
	if round_win <= 0:
		texture_rect.material.set_shader_parameter("progress", 0.5)
	else:
		texture_rect.material.set_shader_parameter("progress", 1)
	
	round_win += 1

func apply_player_color(color: Color):
	texture_rect.material.set_shader_parameter("color_left", color)
