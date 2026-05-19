extends Control
class_name RoundEnd

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var round_winner: RichTextLabel = $RoundWinner

@onready var player_0: Label = $Control/VBoxContainer/HBoxContainer/Player0
@onready var player_1: Label = $Control/VBoxContainer/HBoxContainer/Player1

@onready var texture_rect_left: TextureRect = $Control/VBoxContainer/HBoxContainer/TextureRectLeft
@onready var texture_rect_right: TextureRect = $Control/VBoxContainer/HBoxContainer/TextureRectRight

@onready var next_round: Button = $NextRound

var left_player_id: int = -1
var right_player_id: int = -1
var _players_win: Array[int]

signal animation_finish
signal next_round_button_pressed

func start_animation(winner_id: int, players_win: Array[int], player_main_color: Color):
	_players_win = players_win
	
	var display_num: int = 1 if winner_id == left_player_id else 2
	
	var color_tag: String = "[color=#" + str(player_main_color.to_html()) + "]"
	round_winner.text = color_tag + "Player " + str(display_num) + "[/color] win the round !"
	
	animation_player.play("round_finish")
	
	await animation_player.animation_finished
	
	animation_finish.emit()

func update_score():
	player_0.text = str(_players_win[left_player_id])
	player_1.text = str(_players_win[right_player_id])

func show_next_round_button():
	next_round.show()
	next_round.grab_focus()

func _on_next_round_pressed() -> void:
	next_round_button_pressed.emit()

func change_player_data(left: PlayerCharacterSelection, right: PlayerCharacterSelection):
	left_player_id = left.player_id
	right_player_id = right.player_id
	
	_set_texture_for(texture_rect_left, left)
	_set_texture_for(texture_rect_right, right)

func _set_texture_for(rect: TextureRect, data: PlayerCharacterSelection):
	rect.texture = data.character_texture.get_frame_texture("default", 0)
	rect.material = data.color_skin.color_shader_2d
