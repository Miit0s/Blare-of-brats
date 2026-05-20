extends Control
class_name SharedLifeBar

@onready var life_bar: ColorRect = $LifeBar
@onready var middle_bar: ColorRect = $MiddleBar

@onready var texture_rect_left: TextureRect = $TextureRectLeft
@onready var texture_rect_right: TextureRect = $TextureRectRight
@onready var player_indicator_left: TextureRect = $PlayerIndicatorLeft
@onready var player_indicator_right: TextureRect = $PlayerIndicatorRight
@onready var round_win_indicator_left: RoundWinIndicator = $RoundWinIndicatorLeft
@onready var round_win_indicator_right: RoundWinIndicator = $RoundWinIndicatorRight

@export var player_health: float = 100

@export_range(0, 1, 0.01) var min_middle_bar_hide: float = 0.48
@export_range(0, 1, 0.01) var max_middle_bar_hide: float = 0.52

@export_category("Tween Value")
@export var shader_direction_change_speed: float = 1
@export var shader_value_change_speed: float = 0.3

#Shader stuff
var shader_current_speed: Vector2 = Vector2(0.3, 0.1)
var total_offset: Vector2 = Vector2.ZERO

var target_progress_value: float = 0.5
var progress_bar_value: float = 0.5:
	set(new_value):
		progress_bar_value = clampf(new_value, 0.0, 1.0)
		_progress_bar_value_changed(progress_bar_value)

var left_player_id: int = -1
var right_player_id: int = -1

signal player_win(player_id: int)
signal lifebar_value_change(new_value: float)

func _ready() -> void:
	_progress_bar_value_changed(progress_bar_value)

func _process(delta: float) -> void:
	total_offset += shader_current_speed * delta
	
	total_offset.x = fmod(total_offset.x, 1.0)
	total_offset.y = fmod(total_offset.y, 1.0)
	
	_get_life_bar_shader_material().set_shader_parameter("uv_offset", total_offset)

func _progress_bar_value_changed(new_value):
	if min_middle_bar_hide <= new_value and new_value <= max_middle_bar_hide: middle_bar.hide()
	else: middle_bar.show()
	
	var target_shader_speed: Vector2 = Vector2(0.3, 0.1) if new_value <= 0.5 else Vector2(-0.3, 0.1)
	
	var tween: Tween = create_tween()
	tween.tween_property(
		self,
		"shader_current_speed",
		target_shader_speed,
		shader_direction_change_speed
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	
	_get_life_bar_shader_material().set_shader_parameter("progress", new_value)

func _get_life_bar_shader_material() -> ShaderMaterial:
	return life_bar.material

func add_damage_to_player(player_id: int, damage: float):
	if player_id == left_player_id: target_progress_value -= damage / (player_health * 2)
	elif player_id == right_player_id: target_progress_value += damage / (player_health * 2)
	
	if target_progress_value <= 0: player_win.emit(get_player_id_with_most_health())
	elif target_progress_value >= 1: player_win.emit(get_player_id_with_most_health())
	
	var tween: Tween = create_tween()
	tween.tween_property(
		self,
		"progress_bar_value",
		target_progress_value,
		shader_value_change_speed
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	await tween.finished
	
	lifebar_value_change.emit(progress_bar_value)

func get_player_id_with_least_health() -> int:
	return left_player_id if target_progress_value <= 0.5 else right_player_id

func get_player_id_with_most_health() -> int:
	return left_player_id if target_progress_value >= 0.5 else right_player_id

func reset():
	progress_bar_value = 0.5
	target_progress_value = 0.5

func add_player_win(player_id: int, color_to_apply: Color):
	if player_id == left_player_id:
		round_win_indicator_left.new_round_win(color_to_apply)
	elif player_id == right_player_id:
		round_win_indicator_right.new_round_win(color_to_apply)

func change_player_data(left: PlayerCharacterSelection, right: PlayerCharacterSelection):
	left_player_id = left.player_id
	right_player_id = right.player_id
	
	life_bar.material.set_shader_parameter("color_left", left.color_skin.main_color)
	life_bar.material.set_shader_parameter("color_right", right.color_skin.main_color)
	
	player_indicator_left.self_modulate = left.color_skin.main_color
	player_indicator_right.self_modulate = right.color_skin.main_color
	
	_set_texture_for(texture_rect_left, left)
	_set_texture_for(texture_rect_right, right)

func _set_texture_for(rect: TextureRect, data: PlayerCharacterSelection):
	rect.texture = data.front_texture
	rect.material = data.color_skin.color_shader_2d
