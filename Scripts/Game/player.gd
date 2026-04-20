extends CharacterBody3D
class_name Player

@onready var pick_up_area: Area3D = $PickUpArea

@export_range(0,3) var player_id: int = 0

@export_category("Basic Movement")
@export var speed: float = 8.0
@export var fall_speed: float = 100.0

@export_category("Dash")
@export var dash_speed: float = 20.0
@export var min_dash_speed: float = 5.0
@export var dash_cooldown: float = 0.5
@export var dash_duration: float = 0.3
var _dash_speed_to_apply: float = 0

@export_category("Item")
@export var picked_up_item_distance: float = 1.0
@export var picked_up_movement_smoothing_factor: float = 30.0
var _is_dashing: bool = false
var _dash_can_be_use: bool = true

@export_category("Attack")
@export var slash_arc: float = 120
var attack_cooldown: float = 1
var _can_attack: bool = true

@export_category("Stun")
@export var stun_duration: float = 1

@export_category("Knockback")
@export var knockback_speed: float = 20.0
@export var knockback_duration: float = 0.05
var _is_in_knockback: bool = false
var _knockback_direction: Vector3 = Vector3.ZERO

@export_category("Aim")
@export var lock_after_aim_duration: float = 0.1

@export_category("SFX")
@export var pickup_sound : WwiseEvent
@export var dash_sound : WwiseEvent
@export var switch_sound : WwiseEvent

@export_category("Debug")
@export var static_direction_dash: bool = false
@export var dash_malus: bool = false
@export var blend_static_and_move_direction: bool = false
@export_range(0, 1) var blend_start_threshold: float = 0.5

var _dash_elapsed_time: float = 0.0

var _current_direction: Vector3 = Vector3.RIGHT
var _last_direction: Vector3 = Vector3.RIGHT
var _dash_direction: Vector3 = Vector3.RIGHT

var _suffix: String = ""
var current_picked_item: Item = null

var _is_stun: bool = false
var _is_invincible: bool = false
var _is_aiming: bool = false

signal has_been_hit(player_id: int, damage: float)

func _ready() -> void:
	_suffix = "_" + str(player_id)
	_dash_speed_to_apply = dash_speed

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y = -fall_speed * delta
	
	if _is_stun: return
	
	#Basic movement
	var input: Vector2 = Input.get_vector("Left" + _suffix, "Right" + _suffix, "Up" + _suffix, "Down" + _suffix)
	var direction: Vector3 = Vector3.ZERO
	
	direction.x = input.x
	direction.z = input.y
	
	_current_direction = direction
	
	if _is_in_knockback:
		velocity = _knockback_direction.normalized() * knockback_speed
	elif _is_dashing and not _is_aiming:
		_dash_elapsed_time += delta
		var final_dash_dir: Vector3 = _dash_direction
		
		if blend_static_and_move_direction:
			var progress = clamp(_dash_elapsed_time / dash_duration, 0.0, 1.0)
			
			if progress > blend_start_threshold:
				var mix_factor = (progress - blend_start_threshold) / (1.0 - blend_start_threshold)
				var target_dir = direction if direction != Vector3.ZERO else _dash_direction
				final_dash_dir = _dash_direction.lerp(target_dir, mix_factor)
		if static_direction_dash:
			velocity = _dash_direction.normalized() * _dash_speed_to_apply
		else:
			var d_dir = final_dash_dir if blend_static_and_move_direction else (direction if direction else _last_direction)
			velocity = d_dir.normalized() * _dash_speed_to_apply
	elif direction and not _is_aiming:
		velocity = direction * speed
		_last_direction = direction
	else:
		velocity.x = 0
		velocity.z = 0

	move_and_slide()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Dash" + _suffix) and _dash_can_be_use:
		dash()
	
	if Input.is_action_just_pressed("Drop" + _suffix) and current_picked_item and not current_picked_item.is_attacking and not _is_aiming:
		switch_item()
	
	if Input.is_action_just_pressed("PickUp" + _suffix) and not current_picked_item:
		pick_up()
	
	if Input.is_action_just_pressed("Throw" + _suffix) and current_picked_item and not current_picked_item.is_attacking and not _is_aiming:
		_is_aiming = true
	
	if Input.is_action_just_released("Throw" + _suffix) and current_picked_item and not current_picked_item.is_attacking and _is_aiming:
		throw(_current_direction)
	
	if Input.is_action_just_pressed("Attack" + _suffix) and _can_attack and not _is_aiming:
		attack(_current_direction if _current_direction else _last_direction)
	
	if current_picked_item and not current_picked_item.is_attacking:
		var aim_direction: Vector3 = Vector3.ZERO
		aim_direction = _current_direction if _current_direction else _last_direction
		
		var item_position: Vector3 = self.global_position + aim_direction.normalized() * picked_up_item_distance
		current_picked_item.global_position = lerp(current_picked_item.global_position, item_position, delta * picked_up_movement_smoothing_factor)

func dash():
	_dash_direction = _current_direction
	_dash_elapsed_time = 0.0
	
	_dash_can_be_use = false
	_is_dashing = true
	_is_invincible = true
	
	var dash_speed_tween: Tween = create_tween()
	dash_speed_tween.tween_property(self, "_dash_speed_to_apply", min_dash_speed, dash_duration)
	dash_speed_tween.set_trans(Tween.TRANS_CUBIC)
	dash_speed_tween.set_ease(Tween.EASE_OUT)
	
	get_tree().create_timer(dash_cooldown).timeout.connect(func(): _dash_can_be_use = true)
	dash_speed_tween.finished.connect(
		func():
		if dash_malus:
			_dash_speed_to_apply = 0.0
			await get_tree().create_timer(0.15).timeout
		
		_is_dashing = false
		_is_invincible = false
		_dash_speed_to_apply = dash_speed
	)
	
	dash_sound.post(self)

func pick_up(play_pickup_sound: bool = true):
	var item_in_range: Array[Node3D] = pick_up_area.get_overlapping_bodies()
	if item_in_range.is_empty(): return
	
	var closest_item: Item = _get_closest_item(item_in_range)
	if not closest_item: return
	
	current_picked_item = closest_item
	current_picked_item.item_picked_up(player_id)
	
	if play_pickup_sound: pickup_sound.post(self)

func _get_closest_item(item_in_range: Array[Node3D]) -> Item:
	var current_direction: Vector3 = velocity.normalized() if velocity else _last_direction.normalized()
	var closest_item: Item = null
	var highest_score: float = -1.0
	
	for item: Item in item_in_range:
		if item.is_already_pick or item.has_been_drop: continue
		
		#Direction joueur - item
		var direction_to_item: Vector3 = (item.global_position - global_position).normalized()
		#Alignement item - direction joueur
		var alignement_score: float = current_direction.dot(direction_to_item)
		
		if alignement_score > highest_score:
			highest_score = alignement_score
			closest_item = item
	
	return closest_item

func attack(direction: Vector3):
	if current_picked_item == null: return
	
	_can_attack = false
	current_picked_item.attack()
	_make_attack_movement(direction)
	await get_tree().create_timer(attack_cooldown).timeout
	_can_attack = true

func _make_attack_movement(direction: Vector3):
	var base_angle: float = atan2(direction.x, direction.z)
	
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
		current_picked_item.attack_speed
	)
	
	await slash_tween.finished

func _animate_slash(current_angle: float):
	var offset = Vector3(sin(current_angle), 0, cos(current_angle)) * picked_up_item_distance
	current_picked_item.global_position = global_position + offset

func hit(damage: float):
	if _is_invincible: return
	print("Player " + str(player_id) + " has take " + str(damage))
	
	has_been_hit.emit(player_id, damage)

func knockback(hit_direction: Vector3):
	_knockback_direction = -hit_direction
	_is_in_knockback = true
	await get_tree().create_timer(knockback_duration).timeout
	_is_in_knockback = false

func stun():
	_is_stun = true
	await get_tree().create_timer(stun_duration).timeout
	_is_stun = false

func switch_item():
	if not _pickable_item_nearby(): return
	
	current_picked_item.drop()
	current_picked_item = null
	
	pick_up(false)
	
	switch_sound.post(self)

func throw(direction: Vector3):
	current_picked_item.throw(direction if direction else _last_direction)
	current_picked_item = null
	get_tree().create_timer(lock_after_aim_duration).timeout.connect(func(): _is_aiming = false)

func _pickable_item_nearby() -> bool:
	var item_in_range: Array[Node3D] = pick_up_area.get_overlapping_bodies()
	
	var closest_item: Array[Item] = []
	
	for item: Item in item_in_range:
		if item.is_already_pick or item.has_been_drop: continue
		
		closest_item.append(item)
	
	return !closest_item.is_empty()
