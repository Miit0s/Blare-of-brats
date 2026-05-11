extends Control
class_name RoundEnd

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var round_winner: Label = $RoundWinner
@onready var player_0: Label = $Control/VBoxContainer/HBoxContainer/Player0
@onready var player_1: Label = $Control/VBoxContainer/HBoxContainer/Player1
@onready var next_round: Button = $NextRound

var _players_win: Array[int]

signal animation_finish
signal next_round_button_pressed

func start_animation(players_win: Array[int]):
	_players_win = players_win
	round_winner.text = "Player " + str(players_win.find(players_win.max())) + " win this round"
	
	animation_player.play("round_finish")
	
	await animation_player.animation_finished
	
	animation_finish.emit()

func update_score():
	player_0.text = str(_players_win[0])
	player_1.text = str(_players_win[1])

func show_next_round_button():
	next_round.show()
	next_round.grab_focus()

func _on_next_round_pressed() -> void:
	next_round_button_pressed.emit()
