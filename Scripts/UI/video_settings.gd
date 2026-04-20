extends Control
class_name VideoMenu

@onready var fullscreen: ToggleButtonWithName = $Control/VBoxContainer/Fullscreen
@onready var drop_down_resolution: DropDownList = $Control/VBoxContainer/Resolution
@onready var v_sync: ToggleButtonWithName = $Control/VBoxContainer/VSync
@onready var camera_shake: ToggleButtonWithName = $Control/VBoxContainer/CameraShake
@onready var daltonism: DropDownList = $Control/VBoxContainer/Daltonism

@onready var text_size: DropDownList = $Control/VBoxContainer/TextSize
@onready var toggle_hud: ToggleButtonWithName = $Control/VBoxContainer/ToggleHUD
@onready var hud_size: DropDownList = $Control/VBoxContainer/HUDSize

var resolutions = {
	"16:9": [
		Vector2i(1280, 720), Vector2i(1600, 900), Vector2i(1920, 1080), 
		Vector2i(2560, 1440), Vector2i(3840, 2160)
	],
	"16:10": [
		Vector2i(1280, 800), Vector2i(1440, 900), Vector2i(1680, 1050), 
		Vector2i(1920, 1200), Vector2i(2560, 1600)
	],
	"21:9": [
		Vector2i(2560, 1080), Vector2i(3440, 1440), Vector2i(3840, 1600), 
		Vector2i(5120, 2160)
	],
	"32:9" : [
		Vector2i(3840, 1080), Vector2i(5120, 1440)
	]
}

var current_selected_resolution: Vector2i = Vector2i.ZERO

signal fullscreen_change(fullscreen: bool)
signal resolution_change(resolution: Vector2i)
signal v_sync_change(is_vsync_activate: bool)
signal camera_shake_change(is_camera_shake_activate: bool)
#Daltonism

#Text Size
signal hud_toggle_change(is_hud_activate: bool)
#HUD Size

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_selected_resolution = GameOptions.saved_options.resolution
	setup_resolution_list()


func _on_fullscreen_button_toggled(toggled_on: bool) -> void:
	get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if toggled_on else Window.MODE_WINDOWED
	refresh_resolution()
	
	fullscreen_change.emit(toggled_on)


func _on_v_sync_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_MAILBOX)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	v_sync_change.emit(toggled_on)


func _on_resolution_item_selected(index: int) -> void:
	current_selected_resolution = string_to_screen_res(drop_down_resolution.options_list[index])
	
	refresh_resolution()

func refresh_resolution():
	var screen_resolution = DisplayServer.screen_get_size()
	var scale_factor = float(current_selected_resolution.x) / float(screen_resolution.x)
	
	#UI Scale
	if get_window().mode != Window.MODE_EXCLUSIVE_FULLSCREEN:
		DisplayServer.window_set_size(current_selected_resolution)
		get_window().content_scale_factor = 1.0
	else:
		get_window().content_scale_factor = scale_factor
	
	#3D Resolution Scale
	get_viewport().scaling_3d_scale = scale_factor
	
	resolution_change.emit(current_selected_resolution)

func setup_resolution_list():
	drop_down_resolution.options_list.clear()
	for possible_resolution in get_available_resolutions():
		drop_down_resolution.options_list.append(screen_res_to_string(possible_resolution))
	drop_down_resolution.force_update()

func get_available_resolutions() -> Array[Vector2i]:
	var available: Array[Vector2i] = []
	var screen_idx = DisplayServer.window_get_current_screen()
	var screen_res = DisplayServer.screen_get_size(screen_idx)
	
	for ratio in resolutions:
		for res in resolutions[ratio]:
			if res.x <= screen_res.x and res.y <= screen_res.y and not res in available:
				available.append(res)
	
	if not screen_res in available:
		available.append(screen_res)
	
	available.sort_custom(func(a, b): return a.x < b.x or a.y < b.y)
	
	return available

func screen_res_to_string(screen_resolution: Vector2i) -> String:
	return str(screen_resolution.x) + "x" + str(screen_resolution.y)

func string_to_screen_res(value: String) -> Vector2i:
	var split_string = value.split("x")
	return Vector2i(int(split_string[0]), int(split_string[1]))

func pick_best_windows_resolution():
	var resolution_option_list_size: int = drop_down_resolution.options_list.size()
	drop_down_resolution.select_item(resolution_option_list_size-1)
	_on_resolution_item_selected(resolution_option_list_size-1)

func apply_and_pick_resolution(selected_resolution: Vector2i):
	var index: int = 0
	for string_resolution in drop_down_resolution.options_list:
		if string_to_screen_res(string_resolution) == selected_resolution:
			drop_down_resolution.select_item(index)
			_on_resolution_item_selected(index)
		index += 1
	

func apply_options(option_ressource: OptionsResource):
	fullscreen.set_toggle_button(option_ressource.fullscreen)
	
	if option_ressource.resolution == Vector2i.ZERO:
		pick_best_windows_resolution()
	else:
		apply_and_pick_resolution(option_ressource.resolution)
	
	v_sync.set_toggle_button(option_ressource.activate_v_sync)
	camera_shake.set_toggle_button(option_ressource.activate_camera_shake)
	#Daltonism
	
	#Text Size
	toggle_hud.set_toggle_button(option_ressource.desactivate_hud)
	#HUD Size


func _on_camera_shake_button_toggled(toggled_on: bool) -> void:
	camera_shake_change.emit(toggled_on)


func _on_toggle_hud_button_toggled(toggled_on: bool) -> void:
	hud_toggle_change.emit(toggled_on)
