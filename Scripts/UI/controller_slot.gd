extends Control
class_name ControllerSlot

enum PossibleSkin {
	MAX,
	ASH
}

enum SelectionState {
	EMPTY,
	CHARACTER_SELECTION,
	COLOR_SELECTION,
	READY
}

@onready var controller_slot: TextureRect = $ControllerSlot
@onready var selected_player: SelectedPlayerUI = $SelectedPlayer

@onready var back_player: Control = $BackPlayer
@onready var back_player_texture_rect: TextureRect = $BackPlayer/TextureRect

@export var character_texture: Array[Texture2D]
@export var begin_skin: PossibleSkin = PossibleSkin.MAX

var _player_id: int = -1
var is_slot_available: bool:
	get(): return _player_id == -1

var has_selected_character: bool = false
var is_ready: bool = false

var current_state: SelectionState = SelectionState.EMPTY

signal player_his_ready()
signal player_no_more_ready()

func _ready() -> void:
	selected_player.set_new_character(character_texture[0], begin_skin)
	back_player_texture_rect.texture = character_texture[1]

func switch_to_empty_slot():
	_player_id = -1
	
	has_selected_character = false
	is_ready = false
	
	selected_player.hide()
	back_player.hide()
	controller_slot.show()
	
	current_state = SelectionState.EMPTY

func switch_to_character_selection(player_id: int):
	_player_id = player_id
	
	controller_slot.hide()
	selected_player.set_character_selection_state()
	selected_player.show()
	back_player.show()
	
	current_state = SelectionState.CHARACTER_SELECTION

func switch_to_color_selection():
	has_selected_character = true
	
	back_player.hide()
	selected_player.set_character_color_selection_state()
	
	if current_state == SelectionState.READY:
		player_no_more_ready.emit()
	
	current_state = SelectionState.COLOR_SELECTION

func switch_to_player_ready():
	selected_player.set_ready_state()
	is_ready = true
	
	current_state = SelectionState.READY
	
	player_his_ready.emit()

func swap_character_texture():
	var new_skin: PossibleSkin = PossibleSkin.MAX if begin_skin == PossibleSkin.ASH else PossibleSkin.ASH
	var temp_texture = back_player_texture_rect.texture
	
	back_player_texture_rect.texture = selected_player.texture_rect.texture
	selected_player.set_new_character(temp_texture, new_skin)

func next_character_color():
	selected_player.apply_next_color()

func previous_character_color():
	selected_player.apply_previous_color()

## Return the player id connected to this slot, and -1 if there is any
func get_player_id() -> int:
	return _player_id

func back(player_id: int):
	match SelectionState:
		SelectionState.CHARACTER_SELECTION: switch_to_empty_slot()
		SelectionState.COLOR_SELECTION: switch_to_character_selection(player_id)
		SelectionState.READY: switch_to_color_selection()

func next_state(player_id: int):
	match SelectionState:
		SelectionState.EMPTY: switch_to_character_selection(player_id)
		SelectionState.CHARACTER_SELECTION: switch_to_color_selection()
		SelectionState.COLOR_SELECTION: switch_to_player_ready()
