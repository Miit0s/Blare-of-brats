extends CharacterBody2D
class_name Player

@onready var pick_up_area: Area2D = $PickUpArea

@export_range(0,3) var device_id: int = 0
@export_category("Basic Movement")
@export var speed: float = 300.0
@export_category("Dash")
@export var dash_speed: float = 1500.0
@export var dash_cooldown: float = 0.5
@export var dash_duration: float = 0.08
@export_category("Item")
@export var picked_up_item_distance: float = 100
@export var picked_up_movement_smoothing_factor: float = 30
var _is_dashing: bool = false
var _dash_can_be_use: bool = true
@export_category("Attack")
@export var slash_arc: float = 120
var attack_cooldown: float = 1
var _can_attack: bool = true

var _last_direction: Vector2 = Vector2.RIGHT

var _suffix: String = ""
var current_picked_item: Item = null

func _ready() -> void:
	_suffix = "_" + str(device_id)

func _physics_process(delta: float) -> void:
	#Basic movement
	var direction: Vector2 = Input.get_vector("Left" + _suffix, "Right" + _suffix, "Up" + _suffix, "Down" + _suffix)
	
	if Input.is_action_just_pressed("Dash" + _suffix) and _dash_can_be_use: dash()
	if Input.is_action_just_pressed("PickUp_Throw" + _suffix):
		if current_picked_item and not current_picked_item.is_attacking:
			current_picked_item.throw(direction if direction else _last_direction)
			current_picked_item = null
		else:
			pick_up()
	if Input.is_action_just_pressed("Attack" + _suffix) and _can_attack: attack(direction if direction else _last_direction)

	if _is_dashing:
		if direction: velocity = direction.normalized() * dash_speed
		else: velocity = _last_direction.normalized() * dash_speed
	elif direction:
		velocity = direction * speed
		_last_direction = direction
	else:
		velocity.x = 0
		velocity.y = 0

	move_and_slide()
	
	if current_picked_item and not current_picked_item.is_attacking:
		var item_direction: Vector2 = direction if direction else _last_direction
		var item_position: Vector2 = self.global_position + item_direction.normalized() * picked_up_item_distance
		current_picked_item.global_position = lerp(current_picked_item.global_position, item_position, delta * picked_up_movement_smoothing_factor)

func dash():
	_dash_can_be_use = false
	_is_dashing = true
	get_tree().create_timer(dash_cooldown).timeout.connect(func(): _dash_can_be_use = true)
	get_tree().create_timer(dash_duration).timeout.connect(func(): _is_dashing = false)
	

func pick_up():
	var current_direction: Vector2 = velocity.normalized() if velocity else _last_direction.normalized()
	var item_in_range: Array[Node2D] = pick_up_area.get_overlapping_bodies()
	
	if item_in_range.is_empty(): return
	
	var closest_item: Item = null
	var highest_score: float = -1.0
	
	for item in item_in_range:
		#Direction joueur - item
		var direction_to_item: Vector2 = (item.global_position - global_position).normalized()
		#Alignement item - direction joueur
		var alignement_score: float = current_direction.dot(direction_to_item)
		
		if alignement_score > highest_score:
			highest_score = alignement_score
			closest_item = item
	
	current_picked_item = closest_item

func attack(direction: Vector2):
	if current_picked_item == null: return
	
	_can_attack = false
	current_picked_item.attack()
	make_attack_movement(direction)
	await get_tree().create_timer(attack_cooldown).timeout
	_can_attack = true

func make_attack_movement(direction: Vector2):
	var base_angle: float = direction.angle()
	
	var start_angle: float
	var end_angle: float
	
	var full_circle_angle = fposmod(base_angle, 2 * PI)
	
	if PI / 2 < full_circle_angle and full_circle_angle < PI + (PI / 2):
		start_angle = base_angle + deg_to_rad(slash_arc / 2)
		end_angle = base_angle - deg_to_rad(slash_arc / 2)
	else:
		start_angle = base_angle - deg_to_rad(slash_arc / 2)
		end_angle = base_angle + deg_to_rad(slash_arc / 2)
	
	var slash_tween: Tween = create_tween() \
		.set_trans(Tween.TRANS_QUART) \
		.set_ease(Tween.EASE_OUT)
	
	slash_tween.tween_method(
		_animate_slash,
		start_angle,
		end_angle,
		current_picked_item.attack_duration
	)
	
	await slash_tween.finished
	current_picked_item.rotation = 0

func _animate_slash(current_angle: float):
	#current_picked_item.rotation = current_angle
	
	var offset = Vector2.from_angle(current_angle) * picked_up_item_distance
	current_picked_item.global_position = global_position + offset

func hit():
	pass
