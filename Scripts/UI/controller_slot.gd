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

@export var character_animation_for_skin: Dictionary[PossibleSkin, CharacterAnimation]

@export var back_player_right_sided: bool = false

@export var controller_slot_id: int = 0

@export_category("SFX")
@export var color_select_sound : WwiseEvent
@export var color_back_sound : WwiseEvent

@export_category("Tween")
@export var position_move_duration: float = 0.1


var _player_id: int = -1
var is_slot_available: bool:
	get(): return _player_id == -1

var has_selected_character: bool = false
var is_ready: bool = false

var current_state: SelectionState = SelectionState.EMPTY:
	set(new_value):
		current_state = new_value
		has_change_state.emit(controller_slot_id, current_state)
var current_skin: PossibleSkin

var _select_player_container_begin_position: Vector2
var _is_in_center: bool = false

signal player_his_ready(controller_slot: ControllerSlot)
signal player_no_more_ready(controller_slot: ControllerSlot)
signal has_change_state(controller_slot_id: int, new_state: SelectionState)

func _ready() -> void:
	if back_player_right_sided:
		back_player.position.x = (back_player.position.x * -1) - back_player.size.x
		controller_slot.position.x = (controller_slot.position.x * -1) - controller_slot.size.x + 50
	
	current_skin = begin_skin
	switch_to_empty_slot()
	
	selected_player.set_new_character(character_texture[0], front_texture_begin_material, begin_skin, true)
	back_player.apply_color_and_texture(back_texture_begin_material, character_texture[1])
	
	_select_player_container_begin_position = selected_player.position

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
	
	if _is_in_center:
		_is_in_center = false
		
		var position_tween: Tween = create_tween()
		position_tween.set_ease(Tween.EASE_OUT)
		position_tween.set_trans(Tween.TRANS_QUAD)
		position_tween.tween_property(selected_player, "position", _select_player_container_begin_position, position_move_duration)

func switch_to_color_selection():
	has_selected_character = true
	is_ready = false
	
	back_player.hide()
	selected_player.set_character_color_selection_state()
	
	if current_state == SelectionState.READY:
		player_no_more_ready.emit(self)
	
	current_state = SelectionState.COLOR_SELECTION
	
	if not _is_in_center:
		_is_in_center = true
		
		var select_player_next_position: Vector2 = _select_player_container_begin_position
		var move_by: float = (selected_player.size.x / 2) - 50
		select_player_next_position.x = selected_player.position.x + move_by if back_player_right_sided else selected_player.position.x - move_by
		select_player_next_position.y -= 35

		var position_tween: Tween = create_tween()
		position_tween.set_ease(Tween.EASE_OUT)
		position_tween.set_trans(Tween.TRANS_QUAD)
		position_tween.tween_property(selected_player, "position", select_player_next_position, position_move_duration)

func switch_to_player_ready():
	selected_player.set_ready_state()
	is_ready = true
	
	current_state = SelectionState.READY
	
	player_his_ready.emit(self)

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
	
	color_back_sound.post(self)

func next_state(player_id: int):
	if not is_ready:
		color_select_sound.post(self)
	
	match current_state:
		SelectionState.EMPTY: switch_to_character_selection(player_id)
		SelectionState.CHARACTER_SELECTION: switch_to_color_selection()
		SelectionState.COLOR_SELECTION: switch_to_player_ready()

func get_player_selection() -> PlayerCharacterSelection:
	var player_selection: PlayerCharacterSelection = PlayerCharacterSelection.new()
	
	player_selection.player_id = _player_id
	player_selection.front_texture = selected_player.texture_rect.texture
	player_selection.character_texture = character_animation_for_skin[current_skin]
	player_selection.color_skin = selected_player.get_current_material()
	player_selection.skin = current_skin
	
	return player_selection

func lock_color(color: CharacterColorResource):
	if is_ready and get_player_selection().color_skin == color: return
	
	selected_player.lock_color(color)
	
	for color_option: ColorOptions in selected_player.color_picker.color_options_for_skin.values():
		if color_option.get_current_color_skin() == color:
			if color_option == selected_player.color_picker.current_color_option:
				if not selected_player.apply_next_color():
					selected_player.apply_previous_color()
			else:
				var new_back_player_color: CharacterColorResource = color_option.get_and_select_next_color()
				if new_back_player_color == null:
					new_back_player_color = color_option.get_and_select_previous_color()
				back_player.apply_color_and_texture(new_back_player_color)

func unlock_color(color: CharacterColorResource):
	selected_player.unlock_color(color)
