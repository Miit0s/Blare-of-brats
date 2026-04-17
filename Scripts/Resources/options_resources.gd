extends Resource
class_name OptionsResource

#Game Page
@export var desactivate_on_boarding: bool = false
@export var activate_player_marker: bool = true

#Audio Page
@export var general_volume: float = 100
@export var music_volume: float = 100
@export var sound_design_volume: float = 100
@export var ambiance_volume: float = 100

#Video Page
@export var fullscreen: bool = true
@export var resolution: Vector2i = Vector2i.ZERO
@export var activate_v_sync: bool = true
@export var activate_camera_shake: bool = true
#variable for daltonism here. Have to make a enum for that

@export var text_size: int = 100
@export var desactivate_hud: bool = false
#variable for hud size here. Also have to make a enum

#Control Page
#When the control page will be done, need to save it here
