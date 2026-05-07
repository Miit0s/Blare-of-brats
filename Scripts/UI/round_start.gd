extends Control
class_name RoundStartUI

@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal start_round
signal animation_finish

func start_animation():
	animation_player.play("game_start")
	await animation_player.animation_finished
	animation_finish.emit()

#Trigger in animation
func emit_start_game():
	start_round.emit()
