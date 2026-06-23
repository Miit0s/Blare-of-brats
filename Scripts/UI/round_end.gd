extends Control
class_name RoundEnd

@onready var next_round_button: TextureButton = $NextRoundButton
@onready var score_rich_label: RichTextLabel = $RoundInfo/TextureRect/ScoreRichLabel
@onready var round_rich_label: RichTextLabel = $RoundInfo/TextureRect/RoundRichLabel
@onready var player_icon: PlayerIcon = $RoundInfo/TextureRect/PlayerIcon
@onready var finish_label: Label = $FinishLabel
@onready var round_info: TextureRect = $RoundInfo
@onready var win_text_label: Label = $RoundInfo/TextureRect/WinTextLabel

@export var finish_label_pass_duration: float = 3
@export var info_grow_duration: float = 1
@export var reveal_wait_duration: float = 0.5
@export var icon_and_win_text_grow_duration: float = 0.2

@export_category("Sound")
@export var score_update_sound: WwiseEvent

var _players_win: Array[int]

var round_number: int = 0

signal animation_finish
signal next_round_button_pressed

func _ready() -> void:
	next_round_button.pressed.connect(_on_next_round_pressed)

func start_animation(players_win: Array[int], player_color: CharacterColorResource):
	_players_win = players_win
	
	round_number += 1
	round_rich_label.text = "Round " + str(round_number)
	player_icon.apply_texture_and_color(player_color.color_shader_icon)
	
	finish_label.position.x = -finish_label.size.x
	finish_label.show()
	
	win_text_label.scale = Vector2.ZERO
	player_icon.scale = Vector2.ZERO
	
	round_info.scale = Vector2.ZERO
	round_info.show()
	
	var animation_tween: Tween = create_tween()
	animation_tween.set_ease(Tween.EASE_OUT_IN)
	animation_tween.set_trans(Tween.TRANS_QUART)
	animation_tween.tween_property(finish_label, "position", Vector2(size.x, finish_label.position.y), finish_label_pass_duration)
	animation_tween.set_ease(Tween.EASE_OUT)
	animation_tween.set_trans(Tween.TRANS_BACK)
	animation_tween.tween_property(round_info, "scale", Vector2.ONE, info_grow_duration)
	animation_tween.tween_interval(reveal_wait_duration)
	animation_tween.tween_callback(update_score)
	animation_tween.tween_callback(score_update_sound.post.bind(self))
	animation_tween.tween_interval(0.1)
	animation_tween.set_trans(Tween.TRANS_QUAD)
	animation_tween.tween_property(win_text_label, "scale", Vector2.ONE, icon_and_win_text_grow_duration)
	animation_tween.parallel().tween_property(player_icon, "scale", Vector2.ONE, icon_and_win_text_grow_duration)
	
	await animation_tween.finished
	
	animation_finish.emit()

func hide_animation():
	next_round_button.hide()
	
	var hide_animation_tween: Tween = create_tween()
	hide_animation_tween.set_ease(Tween.EASE_IN)
	hide_animation_tween.set_trans(Tween.TRANS_QUAD)
	hide_animation_tween.tween_property(round_info, "scale", Vector2.ZERO, info_grow_duration)
	hide_animation_tween.tween_callback(self.hide)
	hide_animation_tween.tween_callback(animation_finish.emit)

func update_score():
	score_rich_label.text = str(_players_win[0]) + " - " + str(_players_win[1])

func show_next_round_button():
	next_round_button.show()
	next_round_button.grab_focus()

func _on_next_round_pressed() -> void:
	next_round_button_pressed.emit()
