extends Control
class_name RoundWinIndicator

@onready var one: TextureRect = $One
@onready var two: TextureRect = $Two

var round_win: int = 0

func new_round_win(color_to_apply: Color):
	if round_win <= 0:
		one.modulate = color_to_apply
	else:
		two.modulate = color_to_apply
	
	round_win += 1
