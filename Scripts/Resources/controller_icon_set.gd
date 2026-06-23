extends Resource
class_name ControllerIconSet

enum PlatformName {
	PLAYSTATION,
	XBOX,
	STEAM,
	NINTENDO,
	PLAYSTATION_WHITE,
	XBOX_WHITE,
	STEAM_WHITE,
	NINTENDO_WHITE,
}

@export var platform_name: PlatformName

@export var home_btn: Texture2D
@export var start_btn: Texture2D
@export var select_btn: Texture2D

@export var up_btn: Texture2D
@export var down_btn: Texture2D
@export var left_btn: Texture2D
@export var right_btn: Texture2D

@export var cross_up_btn: Texture2D
@export var cross_down_btn: Texture2D
@export var cross_left_btn: Texture2D
@export var cross_right_btn: Texture2D

@export var joystick_left_btn: Texture2D
@export var joystick_right_btn: Texture2D

@export var left_shoulder_btn: Texture2D
@export var right_shoulder_btn: Texture2D

@export var left_joystick: Texture2D
@export var right_joystick: Texture2D

func get_icon_for_joybutton(button_index: JoyButton) -> Texture2D:
	match button_index:
		JOY_BUTTON_A: return down_btn
		JOY_BUTTON_B: return right_btn
		JOY_BUTTON_X: return left_btn
		JOY_BUTTON_Y: return up_btn
		JOY_BUTTON_BACK: return select_btn
		JOY_BUTTON_GUIDE: return home_btn
		JOY_BUTTON_START: return select_btn
		JOY_BUTTON_LEFT_STICK: return joystick_left_btn
		JOY_BUTTON_RIGHT_STICK: return joystick_right_btn
		JOY_BUTTON_LEFT_SHOULDER: return left_shoulder_btn
		JOY_BUTTON_RIGHT_SHOULDER: return right_shoulder_btn
		JOY_BUTTON_DPAD_UP: return cross_up_btn
		JOY_BUTTON_DPAD_DOWN: return cross_down_btn
		JOY_BUTTON_DPAD_LEFT: return cross_left_btn
		JOY_BUTTON_DPAD_RIGHT: return cross_right_btn
	
	return null

func get_icon_for_joyaxis(button_index: JoyAxis) -> Texture2D:
	match button_index:
		JOY_AXIS_LEFT_X: return left_joystick
		JOY_AXIS_LEFT_Y: return left_joystick
		JOY_AXIS_RIGHT_X: return right_joystick
		JOY_AXIS_RIGHT_Y: return right_joystick
	
	return null
