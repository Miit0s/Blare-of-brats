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
@onready var selected_player: MainCharacterSelection = $SelectedPlayer

@onready var back_player: CharacterSelection = $BackPlayer

@export var character_texture: Array[Texture2D]
@export var begin_skin: PossibleSkin = PossibleSkin.MAX
@export var front_texture_begin_material: CharacterColorResource
@export var back_texture_begin_material: CharacterColorResource

@export var spriteframes_for_skin: Dictionary[PossibleSkin, SpriteFrames]

var _player_id: int = -1
var is_slot_available: bool:
	get(): return _player_id == -1

var has_selected_character: bool = false
var is_ready: bool = false

var current_state: SelectionState = SelectionState.EMPTY
var current_skin: PossibleSkin

signal player_his_ready()
signal player_no_more_ready()

func _ready() -> void:
	current_skin = begin_skin
	switch_to_empty_slot()
	
	selected_player.set_new_character(character_texture[0], front_texture_begin_material, begin_skin)
	back_player.apply_color_and_texture(back_texture_begin_material, character_texture[1])

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
	var new_skin: PossibleSkin = PossibleSkin.MAX if current_skin == PossibleSkin.ASH else PossibleSkin.ASH
	var temp_texture: Texture2D = back_player.texture_rect.texture
	var temp_material: CharacterColorResource = back_player.current_character_color
	
	back_player.apply_color_and_texture(selected_player.current_character_color, selected_player.texture_rect.texture)
	selected_player.set_new_character(temp_texture, temp_material, new_skin)
	
	current_skin = new_skin

func next_character_color():
	selected_player.apply_next_color()

func previous_character_color():
	selected_player.apply_previous_color()

## Return the player id connected to this slot, and -1 if there is any
func get_player_id() -> int:
	return _player_id

func back(player_id: int):
	match current_state:
		SelectionState.CHARACTER_SELECTION: switch_to_empty_slot()
		SelectionState.COLOR_SELECTION: switch_to_character_selection(player_id)
		SelectionState.READY: switch_to_color_selection()

func next_state(player_id: int):
	match current_state:
		SelectionState.EMPTY: 
			switch_to_character_selection(player_id)
			return
		SelectionState.CHARACTER_SELECTION: 
			switch_to_color_selection()
			return
		SelectionState.COLOR_SELECTION: 
			switch_to_player_ready()
			return

func get_player_selection() -> PlayerCharacterSelection:
	var player_selection: PlayerCharacterSelection = PlayerCharacterSelection.new()
	
	player_selection.player_id = _player_id
	player_selection.character_texture = spriteframes_for_skin[current_skin]
	player_selection.color_skin = selected_player.get_current_material()
	player_selection.skin = current_skin
	
	return player_selection
