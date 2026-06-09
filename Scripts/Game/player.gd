extends CharacterBody3D
class_name Player

@onready var pick_up_area: Area3D = $PickUpArea
@onready var walk_smoke: GPUParticles3D = $WalkSmoke
@onready var switch_sprite: Sprite3D = $SwitchSprite
@onready var throw_direction: Node3D = $ThrowDirection
@onready var current_item: Sprite3D = $CurrentItem
@onready var stun_particle: GPUParticles3D = $StunParticle

@export_range(0,3) var player_id: int = 0

@export_category("Basic Movement")
@export var speed: float = 8.0
@export var fall_speed: float = 100.0
@export var speed_change_transition: float = 0.2
var _speed_multiplier: float = 1
var _slow_tween: Tween = null

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
@export var attack_move_speed: float = 20.0
@export var attack_move_duration: float = 0.05
@export var attack_cooldown: float = 1
var _can_attack: bool = true
var _is_attacking: bool = false
var _is_making_attack_move: bool = false

@export_category("Stun")
@export var knockback_stun_duration: float = 1

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
@export var hit_wout_obj: WwiseEvent
@export var launch : WwiseEvent

@export_category("VFX")
@export var hit_effect_duration: float = 0.2
@export var switch_effect_duration: float = 0.4
@export var wall_bounce_particle_prefab: PackedScene

@export_category("Visual")
@export var character_animation: CharacterAnimation

@export_category("Instance")
@export var player_animated_sprite_3d: AnimatedSprite3D
@export var dash_effect: GPUParticles3D
@export var throw_arrow: Sprite3D

var _current_direction: Vector3 = Vector3.BACK
var _last_direction: Vector3 = Vector3.BACK
var _last_wall_hit_normal: Vector3 = Vector3.ZERO

var _suffix: String = ""
var current_picked_item: Item = null

var _is_stun: bool = false
var _is_invincible: bool = false
var _is_aiming: bool = false
var _is_freeze: bool = false

var _attack_move_timer: Tween = null

signal has_been_hit(player_id: int, damage: float)

signal did_dash()
signal pick_up_object()
signal did_attack()
signal did_throw()

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
		if current_picked_item.reverse_attack_dash: velocity = -(_last_direction.normalized()) * attack_move_speed
		else: velocity = _last_direction.normalized() * attack_move_speed
	elif _is_dashing and not _is_aiming and not _is_stun and not _is_attacking and not _is_freeze:
		var dash_direction: Vector3 = direction if direction else _last_direction
		velocity = dash_direction.normalized() * _dash_speed_to_apply
	elif direction and not _is_aiming and not _is_stun and not _is_attacking and not _is_freeze:
		velocity = direction * (speed * _speed_multiplier)
		_last_direction = direction
	else:
		velocity.x = 0
		velocity.z = 0
	
	var velocity_length: float = velocity.length()
	if velocity_length > 0: walk_smoke.emitting = true
	else: walk_smoke.emitting = false
	
	if not _is_stun and not _is_freeze:
		var sprite_direction: Vector3 = _last_direction if direction == Vector3.ZERO else direction
		_update_sprite(sprite_direction, velocity_length > 0)
	
	move_and_slide()
	
	if _is_in_knockback and is_on_wall() and not _has_hit_wall:
		_detect_wall_bounce()

func _process(delta: float) -> void:
	if _is_freeze or _is_stun: return
	
	if Input.is_action_just_pressed("Dash" + _suffix) and _dash_can_be_use:
		dash()
	
	if Input.is_action_just_pressed("Drop" + _suffix) and current_picked_item and not current_picked_item.is_attacking and not _is_aiming:
		switch_item()
	
	if Input.is_action_just_pressed("PickUp" + _suffix) and not current_picked_item:
		pick_up()
	
	if Input.is_action_just_pressed("Throw" + _suffix) and current_picked_item and not _is_aiming:
		if current_picked_item.is_attacking: cancel_animation()
		_is_aiming = true
		#throw_direction.show()
	
	if Input.is_action_just_released("Throw" + _suffix) and current_picked_item and not current_picked_item.is_attacking and _is_aiming:
		throw(_current_direction)
	
	if Input.is_action_just_pressed("Attack" + _suffix) and _can_attack and not _is_aiming and current_picked_item:
		attack(_current_direction if _current_direction else _last_direction)
	
	var aim_direction: Vector3 = Vector3.ZERO
	aim_direction = _current_direction if _current_direction else _last_direction
		
	if current_picked_item and (not current_picked_item.is_attacking):
		var item_position: Vector3 = self.global_position + aim_direction.normalized() * picked_up_item_distance
		current_picked_item.global_position = lerp(current_picked_item.global_position, item_position, delta * picked_up_movement_smoothing_factor)
		
		if aim_direction != Vector3.ZERO:
			current_picked_item.look_at(current_picked_item.global_position + aim_direction)
			#throw_direction.look_at(throw_direction.global_position + aim_direction)
	
	if aim_direction != Vector3.ZERO:
		throw_direction.look_at(throw_direction.global_position + aim_direction)

func dash():
	_dash_can_be_use = false
	_is_dashing = true
	_is_invincible = true
	dash_effect.emitting = true
	_dash_speed_to_apply = dash_speed
	set_collision_layer_value(6, false)
	set_collision_mask_value(6, false)
	
	_update_particle_to_current_sprite()
	
	did_dash.emit()
	
	var dash_speed_tween: Tween = create_tween()
	dash_speed_tween.tween_property(self, "_dash_speed_to_apply", min_dash_speed, dash_duration)
	dash_speed_tween.set_trans(Tween.TRANS_CUBIC)
	dash_speed_tween.set_ease(Tween.EASE_OUT)
	
	get_tree().create_timer(dash_cooldown).timeout.connect(func(): _dash_can_be_use = true)
	dash_speed_tween.finished.connect(
		func(): 
		_is_dashing = false
		_is_invincible = false
		set_collision_layer_value(6, true)
		set_collision_mask_value(6, true)
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
	
	current_item.scale = current_picked_item.item_visual.scale * 0.7
	current_item.rotation.z = current_picked_item.item_visual.rotation.z
	current_item.texture = current_picked_item.item_visual.texture
	current_item.show()
	
	pick_up_object.emit()
	
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
	
	_is_attacking = true
	_is_making_attack_move = true

	_attack_move_timer = create_tween()
	_attack_move_timer.tween_interval(attack_move_duration)
	_attack_move_timer.tween_callback(func(): 
		_is_making_attack_move = false
		current_picked_item.attack(direction)
		_attack_move_timer = null
	)
	
	get_tree().create_timer(attack_cooldown).timeout.connect(func(): _can_attack = true)
	get_tree().create_timer(current_picked_item.attack_speed).timeout.connect(func(): _is_attacking = false)
	
	did_attack.emit()

func cancel_animation():
	_kill_current_animation()
	
	if current_picked_item:
		current_picked_item.cancel_animation()
	
	_is_attacking = false
	_is_making_attack_move = false
	_is_aiming = false
	
	#throw_direction.hide()

func _kill_current_animation():
	if _attack_move_timer:
		_attack_move_timer.kill()
		_attack_move_timer = null

func hit(damage: float, hit_direction: Vector3):
	if _is_invincible: return
	print("Player " + str(player_id) + " has take " + str(damage))
	
	_override_color_effect()
	knockback(hit_direction)
	
	if _is_attacking or _is_aiming:
		cancel_animation()
	
	has_been_hit.emit(player_id, damage)
	hit_wout_obj.post(self)

func knockback(hit_direction: Vector3):
	_knockback_direction = hit_direction
	_is_in_knockback = true
	_knockback_speed_to_apply = knockback_speed
	
	var knockback_speed_tween: Tween = create_tween()
	knockback_speed_tween.set_trans(Tween.TRANS_CUBIC)
	knockback_speed_tween.set_ease(Tween.EASE_OUT)
	knockback_speed_tween.tween_property(self, "_knockback_speed_to_apply", min_dash_speed, knockback_duration)
	
	await knockback_speed_tween.finished
	
	stun(knockback_stun_duration)
	_is_in_knockback = false
	_has_hit_wall = false

func stun(duration: float):
	_is_stun = true
	
	stun_particle.emitting = true
	stun_particle.restart()
	stun_particle.show()
	_update_sprite(_last_direction, false)
	
	await get_tree().create_timer(duration).timeout
	_is_stun = false
	
	player_animated_sprite_3d.play()
	stun_particle.hide()
	stun_particle.emitting = false

func switch_item():
	if not _pickable_item_nearby(): return
	
	current_picked_item.will_be_destroy.disconnect(item_will_be_destroy)
	current_picked_item.drop()
	current_item.hide()
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
	#throw_direction.hide()
	current_picked_item.will_be_destroy.disconnect(item_will_be_destroy)
	current_picked_item.throw(direction if direction else _last_direction)
	current_item.hide()
	current_picked_item = null
	
	get_tree().create_timer(lock_after_aim_duration).timeout.connect(func(): _is_aiming = false)
	
	launch.post(self)
	did_throw.emit()

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
		func(value): player_animated_sprite_3d.material_override.set_shader_parameter("blend_delta", value),
		0.8,
		0.0,
		hit_effect_duration
	)

func _update_sprite(current_direction: Vector3, is_moving: bool):
	if not is_moving:
		if current_direction.z < 0:
			_change_player_sprite(character_animation.idle_animation, "back")
		elif current_direction.x < 0:
			_change_player_sprite(character_animation.idle_animation, "left")
		else:
			_change_player_sprite(character_animation.idle_animation, "right")
	else:
		var animations_index: int = _get_angle_zone(current_direction, character_animation.run_animation.get_animation_names().size())
		match animations_index:
			0: _change_player_sprite(character_animation.run_animation, "front")
			1: _change_player_sprite(character_animation.run_animation, "front_right")
			2: _change_player_sprite(character_animation.run_animation, "side_right")
			3: _change_player_sprite(character_animation.run_animation, "back_right")
			4: _change_player_sprite(character_animation.run_animation, "back")
			5: _change_player_sprite(character_animation.run_animation, "back_left")
			6: _change_player_sprite(character_animation.run_animation, "side_left")
			7: _change_player_sprite(character_animation.run_animation, "front_left")

func _get_angle_zone(direction: Vector3, steps: int) -> int:
	var angle: float = atan2(direction.x, direction.z)
	angle += TAU if angle < 0.0 else 0.0
	return wrapi(round(angle * steps / TAU), 0, steps)

func _change_player_sprite(new_sprite_frames: SpriteFrames, sprite_animation_name: String):
	if player_animated_sprite_3d.sprite_frames == new_sprite_frames and player_animated_sprite_3d.animation == sprite_animation_name: return
	
	player_animated_sprite_3d.sprite_frames = new_sprite_frames
	player_animated_sprite_3d.animation = sprite_animation_name
	player_animated_sprite_3d.play()

	var material_sprite: ShaderMaterial = player_animated_sprite_3d.material_override
	var atlas_texture: AtlasTexture = new_sprite_frames.get_frame_texture(player_animated_sprite_3d.animation, player_animated_sprite_3d.frame)
	material_sprite.set_shader_parameter("main_texture", atlas_texture)

func _update_particle_to_current_sprite():
	var atlas_texture: AtlasTexture = player_animated_sprite_3d.sprite_frames.get_frame_texture(player_animated_sprite_3d.animation, player_animated_sprite_3d.frame)
	var material_dash: ShaderMaterial = dash_effect.material_override
	
	var atlas_size: Vector2 = atlas_texture.atlas.get_size()
	var region: Rect2 = atlas_texture.region
	
	var uv_offset: Vector2 = region.position / atlas_size
	var uv_scale: Vector2 = region.size / atlas_size
	
	material_dash.set_shader_parameter("main_texture", atlas_texture.atlas)
	material_dash.set_shader_parameter("uv_offset", uv_offset)
	material_dash.set_shader_parameter("uv_scale", uv_scale)

func _detect_wall_bounce():
	var collision: KinematicCollision3D = get_last_slide_collision()
	
	if collision:
		_last_wall_hit_normal = collision.get_normal()
		_has_hit_wall = true
		
		var bounce_particle: GPUParticles3D = wall_bounce_particle_prefab.instantiate()
		add_child(bounce_particle)
		
		var collision_position: Vector3 = collision.get_position()
		bounce_particle.global_position = Vector3(global_position.x, global_position.y, collision_position.z)
		bounce_particle.look_at(bounce_particle.global_position + collision.get_normal())
		bounce_particle.finished.connect(bounce_particle.queue_free)
		
		bounce_particle.emitting = true

func freeze():
	_is_freeze = true

func unfreeze():
	_is_freeze = false

func item_will_be_destroy(_item: Item):
	_kill_current_animation()
	current_picked_item.will_be_destroy.disconnect(item_will_be_destroy)
	current_picked_item = null

func apply_skin_and_color(selection: PlayerCharacterSelection):
	character_animation = selection.character_texture
	player_animated_sprite_3d.material_override = selection.color_skin.color_shader_3d
	
	var dash_material: ShaderMaterial = selection.color_skin.color_shader_3d.duplicate()
	dash_material.set_shader_parameter("color_override", Color.WHITE)
	dash_material.set_shader_parameter("blend_delta", 0.5)
	
	dash_effect.material_override = dash_material
	
	throw_arrow.modulate = selection.color_skin.main_color

func apply_slow(speed_multiplier: float, duration: float):
	if _slow_tween:
		_slow_tween.kill()
		_slow_tween = null
	
	_slow_tween = create_tween()
	_slow_tween.set_ease(Tween.EASE_IN)
	_slow_tween.set_trans(Tween.TRANS_QUAD)
	_slow_tween.tween_property(self, "_speed_multiplier", speed_multiplier, speed_change_transition)
	_slow_tween.tween_interval(duration)
	_slow_tween.tween_property(self, "_speed_multiplier", 1, speed_change_transition)
	_slow_tween.finished.connect(func(): _slow_tween = null)
