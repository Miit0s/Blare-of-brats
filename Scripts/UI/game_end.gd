extends Control
class_name GameEnd

@onready var to_main_menu: Button = $ToMainMenu
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var winner: Label = $Winner

signal to_main_menu_button_pressed()

func start_animation(winner_id: int):
	winner.text = "Player " + str(winner_id) + " !"
	
	animation_player.play("game_end")

func _on_to_main_menu_pressed() -> void:
	to_main_menu_button_pressed.emit()

#Trigger in animation player
func focus_on_return_menu_button():
	to_main_menu.grab_focus()
