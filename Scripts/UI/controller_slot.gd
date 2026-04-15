extends Control
class_name ControllerSlot

@onready var label: Label = $Label
@onready var player_skin: TextureRect = $PlayerSkin

var _player_id: int = -1
var is_slot_available: bool:
	get(): return _player_id == -1

func set_player_id(new_id: int):
	_player_id = new_id
	
	label.hide()
	player_skin.show()

func remove_player():
	_player_id = -1
	
	player_skin.hide()
	label.show()

## Return the player id connected to this slot, and -1 if there is any
func get_player_id() -> int:
	return _player_id
