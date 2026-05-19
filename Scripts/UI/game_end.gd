extends Control
class_name GameEnd

@onready var to_main_menu: Button = $ToMainMenu
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var winner: RichTextLabel = $Winner

signal to_main_menu_button_pressed()

func start_animation(winner_id: int, winner_color: Color, left_player_id: int):
	var display_num: int = 1 if winner_id == left_player_id else 2
	var color_tag: String = "[color=#" + str(winner_color.to_html()) + "]"
	winner.text = color_tag + "Player " + str(display_num) + " ![/color]"
	
	animation_player.play("game_end")

func _on_to_main_menu_pressed() -> void:
	to_main_menu_button_pressed.emit()

#Trigger in animation player
func focus_on_return_menu_button():
	to_main_menu.grab_focus()
