extends Control
class_name GameEnd

@onready var restart_button: CustomTextureButton = $HBoxContainer/StatsHolder/ButtonContainer/RestartButton
@onready var to_main_menu_button: CustomTextureButton = $HBoxContainer/StatsHolder/ButtonContainer/ToMainMenuButton

signal to_main_menu_button_pressed

func _ready() -> void:
	to_main_menu_button.pressed.connect(to_main_menu_button_pressed.emit)
	
	focus_on_return_menu_button()

func start_animation(winner_id: int, winner_color: Color, left_player_id: int):
	#TODO: Setup both scene from both side with correct color + all the stats bar
	
	#TODO: Make the animation where stats are reveal, then score, and then player win and loose scene are show
	pass

func focus_on_return_menu_button():
	restart_button.texture_button.grab_focus()
