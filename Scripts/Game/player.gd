extends CharacterBody3D
class_name Player

@onready var pick_up_area: Area3D = $PickUpArea
@onready var wall_detection_area: Area3D = $WallDetectionArea
@onready var sprite_3d: Sprite3D = $Sprite3D
@onready var walk_smoke: GPUParticles3D = $WalkSmoke
@onready var dash_effect: GPUParticles3D = $DashEffect
@onready var switch_sprite: Sprite3D = $SwitchSprite
@onready var feet: Node3D = $Feet

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
@export var attack_move_speed: float = 20.0
@export var attack_move_duration: float = 0.05
@export var attack_cooldown: float = 1
var _can_attack: bool = true
var _is_attacking: bool = false
var _is_making_attack_move: bool = false

@export_category("Stun")
@export var stun_duration: float = 1

@export_category("Knockback")
@export var knockback_speed: float = 20.0
@export var knockback_rebound_multiplier: float = 0.5
@export var knockback_duration: float = 0.05
@export var min_knockback_speed: float = 15.0
var _is_in_knockback: bool = false
var _has_hit_wall: bool = false
var _knockback_direction: Vector3 = Vector3.ZERO
var _knockback_speed_to_apply: float = 0

@export_category("Aim")
@export var lock_after_aim_duration: float = 0.1

@export_category("SFX")
@export var pickup_sound : WwiseEvent
@export var dash_sound : WwiseEvent
@export var switch_sound : WwiseEvent

@export_category("VFX")
@export var hit_effect_duration: float = 0.2
@export var switch_effect_duration: float = 0.4
@export var wall_bounce_particle_prefab: PackedScene

@export_category("Visual")
@export var sprites_frames: SpriteFrames

var _current_direction: Vector3 = Vector3.RIGHT
var _last_direction: Vector3 = Vector3.RIGHT
var _last_wall_hit_normal: Vector3 = Vector3.ZERO

var _suffix: String = ""
var current_picked_item: Item = null

var _is_stun: bool = false
var _is_invincible: bool = false
var _is_aiming: bool = false
var _is_freeze: bool = false

var _attack_tween: Tween = null

signal has_been_hit(player_id: int, damage: float)

func _ready() -> void:
	_suffix = "_" + str(player_id)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y = -fall_speed * delta
	
	#Basic movement
	var input: Vector2 = Input.get_vector("Left" + _suffix, "Right" + _suffix, "Up" + _suffix, "Down" + _suffix)
	var direction: Vector3 = Vector3.ZERO
	
	direction.x = input.x
	direction.z = input.y
	
	_current_direction = direction
	
	if _is_in_knockback:
		if _has_hit_wall:
			velocity = (_knockback_direction.bounce(_last_wall_hit_normal).normalized() * _knockback_speed_to_apply) * knockback_rebound_multiplier
		else:
			velocity = _knockback_direction.normalized() * _knockback_speed_to_apply
	elif _is_making_attack_move:
		velocity = _last_direction.normalized() * attack_move_speed
	elif _is_dashing and not _is_aiming and not _is_stun and not _is_attacking and not _is_freeze:
		var dash_direction: Vector3 = direction if direction else _last_direction
		velocity = dash_direction.normalized() * _dash_speed_to_apply
	elif direction and not _is_aiming and not _is_stun and not _is_attacking and not _is_freeze:
		velocity = direction * speed
		_last_direction = direction
	else:
		velocity.x = 0
		velocity.z = 0
	
	if velocity.length() > 0: walk_smoke.emitting = true
	else: walk_smoke.emitting = false
	
	_update_sprite(direction)
	
	move_and_slide()

func _process(delta: float) -> void:
	if _is_freeze or _is_stun: return
	
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
	
	if current_picked_item and (not current_picked_item.is_attacking or current_picked_item.distance):
		var aim_direction: Vector3 = Vector3.ZERO
		aim_direction = _current_direction if _current_direction else _last_direction
		
		var item_position: Vector3 = self.global_position + aim_direction.normalized() * picked_up_item_distance
		current_picked_item.global_position = lerp(current_picked_item.global_position, item_position, delta * picked_up_movement_smoothing_factor)

func dash():
	_dash_can_be_use = false
	_is_dashing = true
	_is_invincible = true
	dash_effect.emitting = true
	_dash_speed_to_apply = dash_speed
	
	var dash_speed_tween: Tween = create_tween()
	dash_speed_tween.tween_property(self, "_dash_speed_to_apply", min_dash_speed, dash_duration)
	dash_speed_tween.set_trans(Tween.TRANS_CUBIC)
	dash_speed_tween.set_ease(Tween.EASE_OUT)
	
	get_tree().create_timer(dash_cooldown).timeout.connect(func(): _dash_can_be_use = true)
	dash_speed_tween.finished.connect(
		func(): 
		_is_dashing = false
		_is_invincible = false
	)
	
	dash_sound.post(self)

func pick_up(play_pickup_sound: bool = true):
	var item_in_range: Array[Node3D] = pick_up_area.get_overlapping_bodies()
	if item_in_range.is_empty(): return
	
	var closest_item: Item = _get_closest_item(item_in_range)
	if not closest_item: return
	
	current_picked_item = closest_item
	current_picked_item.item_picked_up(player_id)
	current_picked_item.will_be_destroy.connect(item_will_be_destroy)
	
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
	
	if current_picked_item.distance:
		current_picked_item.attack(direction)
	else:
		_is_attacking = true
		_is_making_attack_move = true
		
		get_tree().create_timer(attack_move_duration).timeout.connect(func(): 
			_is_making_attack_move = false
			current_picked_item.slash_look_at(self.global_position)
			current_picked_item.attack(direction)
			_make_attack_movement(direction)
		)
	
	get_tree().create_timer(attack_cooldown).timeout.connect(func(): _can_attack = true)
	get_tree().create_timer(current_picked_item.attack_speed).timeout.connect(func(): _is_attacking = false)

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
	_attack_tween = slash_tween
	
	slash_tween.tween_method(
		_animate_slash,
		start_angle,
		end_angle,
		current_picked_item.attack_speed
	)
	
	await slash_tween.finished
	_attack_tween = null

func _animate_slash(current_angle: float):
	var offset = Vector3(sin(current_angle), 0, cos(current_angle)) * picked_up_item_distance
	current_picked_item.global_position = global_position + offset

func cancel_animation():
	if _attack_tween:
		_attack_tween.stop()
	
	if current_picked_item:
		current_picked_item.cancel_animation()
	
	_is_attacking = false
	_is_making_attack_move = false
	_is_aiming = false

func hit(damage: float, hit_direction: Vector3):
	if _is_invincible: return
	print("Player " + str(player_id) + " has take " + str(damage))
	
	_override_color_effect()
	knockback(hit_direction)
	
	if _is_attacking or _is_aiming:
		cancel_animation()
	
	has_been_hit.emit(player_id, damage)

func knockback(hit_direction: Vector3):
	_knockback_direction = hit_direction
	_is_in_knockback = true
	_knockback_speed_to_apply = knockback_speed
	
	var knockback_speed_tween: Tween = create_tween()
	knockback_speed_tween.tween_property(self, "_knockback_speed_to_apply", min_dash_speed, knockback_duration)
	knockback_speed_tween.set_trans(Tween.TRANS_CUBIC)
	knockback_speed_tween.set_ease(Tween.EASE_OUT)
	
	await knockback_speed_tween.finished
	
	stun()
	_is_in_knockback = false
	_has_hit_wall = false

func stun():
	_is_stun = true
	await get_tree().create_timer(stun_duration).timeout
	_is_stun = false

func switch_item():
	if not _pickable_item_nearby(): return
	
	current_picked_item.drop()
	current_picked_item = null
	
	pick_up(false)
	
	var sprite_with_new_rotation: Vector3 = switch_sprite.rotation
	sprite_with_new_rotation.z += deg_to_rad(180)
	
	switch_sprite.show()
	var switch_tween: Tween = create_tween()
	switch_tween.set_trans(Tween.TRANS_BACK)
	switch_tween.set_ease(Tween.EASE_OUT)
	switch_tween.tween_property(switch_sprite, "rotation", sprite_with_new_rotation, switch_effect_duration)
	switch_tween.tween_callback(func():
		await get_tree().create_timer(0.2).timeout
		switch_sprite.hide()
	)
	
	switch_sound.post(self)

func throw(direction: Vector3):
	current_picked_item.will_be_destroy.disconnect(item_will_be_destroy)
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

func _override_color_effect():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	tween.tween_method(
		func(value): sprite_3d.material_override.set_shader_parameter("blend_delta", value),
		0.8,
		0.0,
		hit_effect_duration
	)

func _update_sprite(current_direction: Vector3):
	var sprite_index: int = _get_angle_zone(current_direction, sprites_frames.get_frame_count("default"))
	_change_player_sprite(sprites_frames.get_frame_texture("default", sprite_index))

func _get_angle_zone(direction: Vector3, steps: int) -> int:
	var angle: float = atan2(direction.x, direction.z)
	angle += TAU if angle < 0.0 else 0.0
	return wrapi(round(angle * steps / TAU), 0, steps)

func _change_player_sprite(new_sprite: Texture2D):
	sprite_3d.texture = new_sprite
	
	var material_sprite: ShaderMaterial = sprite_3d.material_override
	var material_dash: ShaderMaterial = dash_effect.material_override
	
	material_sprite.set_shader_parameter("sprite_texture", new_sprite)
	material_sprite.set_shader_parameter("uv_offset", Vector2.ZERO)
	material_sprite.set_shader_parameter("uv_scale", Vector2.ONE)
	
	if new_sprite is AtlasTexture:
		var atlas_size: Vector2 = new_sprite.atlas.get_size()
		var region: Rect2 = new_sprite.region
		
		var uv_offset: Vector2 = region.position / atlas_size
		var uv_scale: Vector2 = region.size / atlas_size
		
		material_dash.set_shader_parameter("sprite_texture", new_sprite.atlas)
		material_dash.set_shader_parameter("uv_offset", uv_offset)
		material_dash.set_shader_parameter("uv_scale", uv_scale)
	else:
			material_dash.set_shader_parameter("sprite_texture", new_sprite)
			material_dash.set_shader_parameter("uv_offset", Vector2.ZERO)
			material_dash.set_shader_parameter("uv_scale", Vector2.ONE)


func _on_wall_detection_area_body_entered(_body: Node3D) -> void:
	if not _is_in_knockback: return
	
	var ray_direction = _knockback_direction.normalized() * 2.0
	var target_position = global_position + ray_direction
	
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
		global_position, 
		target_position, 
		wall_detection_area.collision_mask,
		[self]
	)
	
	var result: Dictionary = space_state.intersect_ray(query)
	
	_last_wall_hit_normal = result.normal
	_has_hit_wall = true
	
	var bounce_particle: GPUParticles3D = wall_bounce_particle_prefab.instantiate()
	add_child(bounce_particle)
	
	bounce_particle.global_position = result.position
	bounce_particle.look_at(result.position + result.normal)
	bounce_particle.finished.connect(bounce_particle.queue_free)
	
	bounce_particle.emitting = true

func freeze():
	_is_freeze = true

func unfreeze():
	_is_freeze = false

func item_will_be_destroy(_item: Item):
	current_picked_item.will_be_destroy.disconnect(item_will_be_destroy)
	current_picked_item = null
