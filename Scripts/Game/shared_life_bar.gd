extends Control
class_name SharedLifeBar

@onready var life_bar: ColorRect = $LifeBar
@onready var middle_bar: ColorRect = $MiddleBar

@export var player_health: float = 100

@export_range(0, 1, 0.01) var min_middle_bar_hide: float = 0.48
@export_range(0, 1, 0.01) var max_middle_bar_hide: float = 0.52

@export_category("Tween Value")
@export var shader_direction_change_speed: float = 1
@export var shader_value_change_speed: float = 0.3

#Shader stuff
var shader_current_speed: Vector2 = Vector2(0.3, 0.1)
var total_offset: Vector2 = Vector2.ZERO

var progress_bar_value: float = 0.5:
	set(new_value):
		var clamped_value: float = minf(1.0, maxf(0, new_value))
		progress_bar_value = clamped_value
		_progress_bar_value_changed(progress_bar_value)

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
	var progress_bar_with_damage: float = progress_bar_value
	
	if player_id == 0: progress_bar_with_damage -= damage / (player_health * 2)
	elif player_id == 1: progress_bar_with_damage += damage / (player_health * 2)
	
	var tween: Tween = create_tween()
	tween.tween_property(
		self,
		"progress_bar_value",
		progress_bar_with_damage,
		shader_value_change_speed
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
