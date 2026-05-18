extends Control
class_name RoundEnd

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var round_winner: RichTextLabel = $RoundWinner

@onready var player_0: Label = $Control/VBoxContainer/HBoxContainer/Player0
@onready var player_1: Label = $Control/VBoxContainer/HBoxContainer/Player1

@onready var texture_rect_left: TextureRect = $Control/VBoxContainer/HBoxContainer/TextureRectLeft
@onready var texture_rect_right: TextureRect = $Control/VBoxContainer/HBoxContainer/TextureRectRight

@onready var next_round: Button = $NextRound

var _players_win: Array[int]

signal animation_finish
signal next_round_button_pressed

func start_animation(players_win: Array[int], player_selection_data: PlayerCharacterSelection):
	_players_win = players_win
	
	var color_tag: String = "[color=#" + str(player_selection_data.color_skin.main_color.to_html()) + "]"
	round_winner.text = color_tag + "Player " + str(players_win.find(players_win.max()) + 1) + "[/color] win this round"
	
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

func change_player_data(left: PlayerCharacterSelection, right: PlayerCharacterSelection):
	_set_texture_for(texture_rect_left, left)
	_set_texture_for(texture_rect_right, right)

func _set_texture_for(rect: TextureRect, data: PlayerCharacterSelection):
	rect.texture = data.character_texture.get_frame_texture("default", 0)
	rect.material = data.color_skin.color_shader_2d
