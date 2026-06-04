extends Control
class_name SharedLifeBar

@onready var life_bar: TextureRect = $LifeBar
@onready var middle_bar: ColorRect = $MiddleBar

@onready var color_versus_container: Control = $LifeBarMask/ColorVersusContainer
@onready var color_versus_animated_sprite_2d: AnimatedSprite2D = $LifeBarMask/ColorVersusContainer/ColorVersusAnimatedSprite2D

@export var player_health: float = 100

@export_range(0, 1, 0.01) var min_middle_bar_hide: float = 0.48
@export_range(0, 1, 0.01) var max_middle_bar_hide: float = 0.52

@export var shader_value_change_speed: float = 0.3

var target_progress_value: float = 0.5
var progress_bar_value: float = 0.5:
	set(new_value):
		progress_bar_value = clampf(new_value, 0.0, 1.0)
		_progress_bar_value_changed(progress_bar_value)
		_set_color_versus_position_to_new_progress_bar_value()

var left_player_id: int = -1
var right_player_id: int = -1

signal player_win(player_id: int)
signal lifebar_value_change(new_value: float)

func _ready() -> void:
	_progress_bar_value_changed(progress_bar_value)

func _progress_bar_value_changed(new_value):
	if min_middle_bar_hide <= new_value and new_value <= max_middle_bar_hide: middle_bar.hide()
	else: middle_bar.show()
	
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

func change_player_data(left: PlayerCharacterSelection, right: PlayerCharacterSelection):
	left_player_id = left.player_id
	right_player_id = right.player_id
	
	life_bar.material.set_shader_parameter("color_left", left.color_skin.main_color)
	life_bar.material.set_shader_parameter("color_right", right.color_skin.main_color)
	
	color_versus_animated_sprite_2d.material.set_shader_parameter("replace_0", left.color_skin.main_color)
	color_versus_animated_sprite_2d.material.set_shader_parameter("replace_1", right.color_skin.main_color)

func _set_texture_for(rect: TextureRect, data: PlayerCharacterSelection):
	rect.texture = data.front_texture
	rect.material = data.color_skin.color_shader_2d

func _set_color_versus_position_to_new_progress_bar_value():
	var texture_size: Vector2 = life_bar.texture.get_size()
	var rect_size: Vector2 = life_bar.size
	
	var scale_factor: float = min(rect_size.x / texture_size.x, rect_size.y / texture_size.y)
	var actual_width: float = texture_size.x * scale_factor
	
	var offset_x: float = (rect_size.x - actual_width) / 2.0
	
	var final_x: float = life_bar.position.x + offset_x + (actual_width * progress_bar_value)
	final_x -= color_versus_container.size.x / 2.0
	
	color_versus_container.position.x = final_x
