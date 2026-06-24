extends Node

@export var bank: WwiseBank
@export var main_music_event: WwiseEvent

@export_group("Main Music State")
@export var start_menu: WwiseState
@export var main_menu: WwiseState
@export var sound_stop: WwiseState
@export var phase_1: WwiseState
@export var phase_2: WwiseState
@export var phase_3: WwiseState
@export var phase_danger: WwiseState
@export var win: WwiseState

func _enter_tree() -> void:
	bank.load()

func _exit_tree() -> void:
	bank.unload()

func _ready() -> void:
	main_music_event.post(self)
	sound_stop.set_value()

func set_start_menu_state():
	start_menu.set_value()

func set_main_menu_state():
	main_menu.set_value()

func set_sound_stop_state():
	sound_stop.set_value()

func set_phase_1_state():
	phase_1.set_value()

func set_phase_2_state():
	phase_2.set_value()

func set_phase_3_state():
	phase_3.set_value()

func set_phase_danger_state():
	phase_danger.set_value()

func set_win_state():
	win.set_value()
