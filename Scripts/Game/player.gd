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
@export var min_stun_for_feedback: float = 1.0

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

@export_category("Sound")
@export var pickup_sound : WwiseEvent
@export var dash_sound : WwiseEvent
@export var switch_sound : WwiseEvent
@export var hit_wout_obj: WwiseEvent
@export var launch : WwiseEvent
@export var stun_sound : WwiseEvent

@export_category("VFX")
@export var hit_effect_duration: float = 0.2
@export var switch_effect_duration: float = 0.4
@export var wall_bounce_particle_prefab: PackedScene

@export_category("Visual")
@export var character_animation: CharacterAnimation
@export_group("Squash and Stretch")
@export var squash_force: float = 0.05
@export var squash_duration: float = 0.1
@export var stretch_force: float = 0.05
@export var stretch_duration: float = 0.1
@export var back_to_normal_duration: float = 0.1

@export_category("Vibration")
@export_group("On Hit")
@export var damage_for_max_vibration: float = 5.0
@export var vibration_duration_on_hit: float = 0.2
@export_group("On Object Destroy")
@export_range(0, 1) var vibration_force_on_objet_destroy: float = 0.8
@export var vibration_duration_on_objet_destroy: float = 0.2
@export_group("On Slow")
@export_range(0, 1) var vibration_force_on_slow: float = 0.1
@export_group("On Pick up")
@export_range(0, 1) var vibration_force_on_pickup: float = 0.1
@export var vibration_duration_on_pickup: float = 0.1
@export_group("On Hit other player")
@export_range(0, 1) var vibration_force_on_hit_other_player: float = 0.8
@export var vibration_duration_on_hit_other_player: float = 0.1
@export_group("On Stun")
@export_range(0, 1) var vibration_force_on_stun: float = 0.1
@export_group("On Dash")
@export_range(0, 1) var vibration_force_on_dash: float = 0.1
@export var vibration_duration_on_dash: float = 0.3
@export_group("On Throw")
@export_range(0, 1) var vibration_force_on_throw: float = 0.3
@export var vibration_duration_on_throw: float = 0.1

@export_category("Time change")
@export var freeze_frame_duration: float = 0.05
@export var minimal_damage_for_trigger: float = 1.5

@export_category("Instance")
@export var player_animated_sprite_3d: AnimatedSprite3D
@export var animated_sprite_3d_for_offset: AnimatedSprite3D
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
var _is_playing_attacking_animation: bool = false:
	set(new_value):
		_is_playing_attacking_animation = new_value
		if not _is_playing_attacking_animation:
			animated_sprite_3d_for_offset.hide()
			player_animated_sprite_3d.show()

var _input_cooldown_duration: float = 0.05
var _is_in_input_cooldown: bool = false
var _input_cooldown: float = 0.0

var _has_press_dash: bool = false
var _has_press_attack: bool = false
var _has_press_throw: bool = false
var _has_release_throw: bool = false
var _has_press_drop: bool = false
var _has_press_pickup: bool = false

var _attack_move_timer: Tween = null

var skin: ControllerSlot.PossibleSkin

signal has_been_hit(player_id: int, damage: float, direction: Vector3)

signal did_dash()
signal pick_up_object()
signal did_attack()
signal did_throw()

func _ready() -> void:
	_suffix = "_" + str(player_id)
	animated_sprite_3d_for_offset.animation_finished.connect(func(): _is_playing_attacking_animation = false)

func _physics_process(delta: float) -> void:
	_process_action_with_priorities(delta)
	
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
	var is_moving: bool = velocity_length > 0
	
	if is_moving: walk_smoke.emitting = true
	else: walk_smoke.emitting = false
	
	if not _is_stun and not _is_freeze and not _is_attacking:
		if _is_playing_attacking_animation:
			if not is_moving: return
			else: _is_playing_attacking_animation = false
		
		var sprite_direction: Vector3 = _last_direction if direction == Vector3.ZERO else direction
		_update_sprite(sprite_direction, is_moving)
	
	move_and_slide()
	
	if _is_in_knockback and is_on_wall() and not _has_hit_wall:
		_detect_wall_bounce()

func _process(delta: float) -> void:
	_update_material_to_current_texture(player_animated_sprite_3d)
	_update_material_to_current_texture(animated_sprite_3d_for_offset)
	
	if _is_freeze or _is_stun: return
	
	var aim_direction: Vector3 = Vector3.ZERO
	aim_direction = _current_direction if _current_direction else _last_direction
		
	if current_picked_item and not current_picked_item.is_attacking:
		var item_position: Vector3 = self.global_position + aim_direction.normalized() * picked_up_item_distance
		current_picked_item.global_position = lerp(current_picked_item.global_position, item_position, delta * picked_up_movement_smoothing_factor)
		
		if not aim_direction.is_equal_approx(Vector3.ZERO):
			current_picked_item.look_at(current_picked_item.global_position + aim_direction)
	
	var throw_aim_destination: Vector3 = throw_direction.global_position + aim_direction
	if not aim_direction.is_equal_approx(Vector3.ZERO) or throw_direction.global_position.is_equal_approx(throw_aim_destination):
		throw_direction.look_at(throw_aim_destination)

func _process_action_with_priorities(delta: float) -> void:
	if _is_in_input_cooldown:
		_input_cooldown += delta
		if _input_cooldown >= _input_cooldown_duration: 
			_is_in_input_cooldown = false
			_input_cooldown = 0.0
		else:
			_reset_requests()
			return
	
	if _is_freeze or _is_stun:
		_reset_requests()
		return
	
	if _has_press_dash and _dash_can_be_use:
		dash()
		_is_in_input_cooldown = true
	elif _has_press_attack and _can_attack and not _is_aiming and current_picked_item:
		attack(_current_direction if _current_direction else _last_direction)
		_is_in_input_cooldown = true
	elif _has_press_throw and current_picked_item and not _is_aiming:
		if current_picked_item.is_attacking: cancel_animation()
		_is_aiming = true
		_is_in_input_cooldown = true
	elif _has_release_throw and current_picked_item and not current_picked_item.is_attacking and _is_aiming:
		throw(_current_direction)
		_is_in_input_cooldown = true
	elif _has_press_pickup and not current_picked_item:
		pick_up()
		_is_in_input_cooldown = true
	elif _has_press_drop and current_picked_item and not current_picked_item.is_attacking and not _is_aiming:
		switch_item()
		_is_in_input_cooldown = true
	
	_reset_requests()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Dash" + _suffix):
		_has_press_dash = true
	elif event.is_action_pressed("Attack" + _suffix):
		_has_press_attack = true
	elif event.is_action_pressed("Throw" + _suffix):
		_has_press_throw = true
	elif event.is_action_released("Throw" + _suffix):
		_has_release_throw = true
	
	if event.is_action_pressed("Drop" + _suffix):
		_has_press_drop = true
	if event.is_action_pressed("PickUp" + _suffix):
		_has_press_pickup = true

func _reset_requests() -> void:
	_has_press_dash = false
	_has_press_attack = false
	if not _has_press_throw:       #Si throw a été presser, on laisse l'action release log
		_has_release_throw = false
	_has_press_throw = false
	_has_press_drop = false
	_has_press_pickup = false

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
	
	VibrationManager.start_joy_vibration(player_id, vibration_force_on_dash, 0, vibration_duration_on_dash)
	dash_sound.post(self)

func pick_up(play_pickup_sound: bool = true):
	var item_in_range: Array[Node3D] = pick_up_area.get_overlapping_bodies()
	if item_in_range.is_empty(): return
	
	var closest_item: Item = _get_closest_item(item_in_range)
	if not closest_item: return
	
	current_picked_item = closest_item
	current_picked_item.item_picked_up(player_id, self)
	current_picked_item.will_be_destroy.connect(item_will_be_destroy)
	current_picked_item.has_hit_player.connect(_has_hit_other_player)
	
	current_item.scale = current_picked_item.item_visual.scale * 0.7
	current_item.rotation.z = current_picked_item.item_visual.rotation.z
	current_item.texture = current_picked_item.item_visual.texture
	current_item.show()
	
	pick_up_object.emit()
	
	VibrationManager.start_joy_vibration(player_id, vibration_force_on_pickup, 0, vibration_duration_on_pickup)
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
		_apply_attack_animation(direction)
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
	animated_sprite_3d_for_offset.hide()
	animated_sprite_3d_for_offset.stop()
	player_animated_sprite_3d.show()
	
	if _attack_move_timer:
		_attack_move_timer.kill()
		_attack_move_timer = null

func hit(damage: float, hit_direction: Vector3, has_knockback: bool = true):
	if _is_invincible: return
	
	_override_color_effect()
	
	if has_knockback:
		knockback(hit_direction)
	
	if _is_attacking or _is_aiming:
		cancel_animation()
	
	has_been_hit.emit(player_id, damage, hit_direction)
	
	VibrationManager.start_joy_vibration(player_id, inverse_lerp(0, damage_for_max_vibration, damage), 0, vibration_duration_on_hit)
	hit_wout_obj.post(self)
	
	if damage >= minimal_damage_for_trigger:
		_freeze_frame_effect()
		_squash_and_stretch_effect()

func _freeze_frame_effect():
	var freeze_frame_tween: Tween = create_tween()
	freeze_frame_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	freeze_frame_tween.tween_property(get_tree(), "paused", true, 0)
	freeze_frame_tween.tween_interval(freeze_frame_duration)
	freeze_frame_tween.tween_property(get_tree(), "paused", false, 0)

func _squash_and_stretch_effect():
	var start_scale: Vector3 = player_animated_sprite_3d.scale
	var squash_scale: Vector3 = Vector3(start_scale.x + squash_force, start_scale.y - squash_force, start_scale.z)
	var stretch_scale: Vector3 = Vector3(start_scale.x - stretch_force, start_scale.y + stretch_force, start_scale.z)
	
	var squash_and_stretch_tween: Tween = create_tween()
	squash_and_stretch_tween.set_ease(Tween.EASE_OUT)
	squash_and_stretch_tween.set_trans(Tween.TRANS_QUART)
	squash_and_stretch_tween.tween_property(player_animated_sprite_3d, "scale", squash_scale, squash_duration)
	squash_and_stretch_tween.tween_property(player_animated_sprite_3d, "scale", stretch_scale, stretch_duration)
	squash_and_stretch_tween.tween_property(player_animated_sprite_3d, "scale", start_scale, back_to_normal_duration)

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
	
	if duration >= min_stun_for_feedback:
		VibrationManager.start_joy_vibration(player_id, vibration_force_on_stun, 0, duration)
		stun_sound.post(self)
	
	_update_sprite(_last_direction, false)
	
	await get_tree().create_timer(duration).timeout
	_is_stun = false
	
	if not _is_freeze:
		player_animated_sprite_3d.play()
	
	stun_particle.hide()
	stun_particle.emitting = false

func switch_item():
	if not _pickable_item_nearby(): return
	
	current_picked_item.will_be_destroy.disconnect(item_will_be_destroy)
	current_picked_item.has_hit_player.disconnect(_has_hit_other_player)
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
	current_picked_item.has_hit_player.disconnect(_has_hit_other_player)
	current_picked_item.throw(direction if direction else _last_direction)
	current_item.hide()
	current_picked_item = null
	
	get_tree().create_timer(lock_after_aim_duration).timeout.connect(func(): _is_aiming = false)
	
	VibrationManager.start_joy_vibration(player_id, vibration_force_on_throw, 0, vibration_duration_on_throw)
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
		_display_idle_sprite_no_item(current_direction)
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

func _display_idle_sprite_no_item(current_direction: Vector3):
	if current_direction.z < 0:
		_change_player_sprite(character_animation.idle_animation, "back")
	elif current_direction.x < 0:
		_change_player_sprite(character_animation.idle_animation, "left")
	else:
		_change_player_sprite(character_animation.idle_animation, "right")

func _display_idle_sprite_with_item(current_direction: Vector3):
	var idle_animation: SpriteFrames = current_picked_item.animations[skin].idle_animation
	var number_of_side: int = idle_animation.get_animation_names().size()
	var animations_index: int = _get_angle_zone(current_direction, number_of_side)
	
	if number_of_side == 2:
		match animations_index:
			0: _change_player_sprite(idle_animation, "left")
			1: _change_player_sprite(idle_animation, "right")
	else:
		match animations_index:
			0: _change_player_sprite(idle_animation, "front")
			1: _change_player_sprite(idle_animation, "right")
			2: _change_player_sprite(idle_animation, "back")
			3: _change_player_sprite(idle_animation, "left")

func _apply_attack_animation(attack_direction: Vector3):
	_is_playing_attacking_animation = true
	
	var attack_animation: SpriteFrames = current_picked_item.animations[skin].attack_animations
	var number_of_side: int = attack_animation.get_animation_names().size()
	var animations_index: int = _get_angle_zone(attack_direction, number_of_side)
	var sprite_offset: Vector2 = Vector2.ZERO
	
	var correct_anim_name: String = "default"
	if number_of_side == 2:
		animations_index = _get_angle_zone(attack_direction, number_of_side, PI / 2)
		match animations_index:
			0: 
				correct_anim_name = "left"
				sprite_offset = current_picked_item.animations[skin].attack_offset_left
			1: 
				correct_anim_name = "right"
				sprite_offset = current_picked_item.animations[skin].attack_offset_right
	else:
		match animations_index:
			0: 
				correct_anim_name = "front"
				sprite_offset = current_picked_item.animations[skin].attack_offset_front
			1: 
				correct_anim_name = "right"
				sprite_offset = current_picked_item.animations[skin].attack_offset_right
			2: 
				correct_anim_name = "back"
				sprite_offset = current_picked_item.animations[skin].attack_offset_back
			3: 
				correct_anim_name = "left"
				sprite_offset = current_picked_item.animations[skin].attack_offset_left
	
	_change_player_sprite(attack_animation, correct_anim_name, sprite_offset)


func _get_angle_zone(direction: Vector3, steps: int, angle_offset: float = 0.0) -> int:
	var angle: float = atan2(direction.x, direction.z) + angle_offset
	angle += TAU if angle < 0.0 else 0.0
	return wrapi(round(angle * steps / TAU), 0, steps)

func _change_player_sprite(new_sprite_frames: SpriteFrames, sprite_animation_name: String, sprite_offset: Vector2 = Vector2.ZERO):
	if player_animated_sprite_3d.sprite_frames == new_sprite_frames and player_animated_sprite_3d.animation == sprite_animation_name: return
	
	if sprite_offset != Vector2.ZERO:
		animated_sprite_3d_for_offset.position = Vector3(sprite_offset.x, sprite_offset.y, 0)
		animated_sprite_3d_for_offset.sprite_frames = new_sprite_frames
		animated_sprite_3d_for_offset.animation = sprite_animation_name
		
		await get_tree().process_frame
		
		player_animated_sprite_3d.hide()
		animated_sprite_3d_for_offset.show()
		
		animated_sprite_3d_for_offset.play()
	else:
		player_animated_sprite_3d.sprite_frames = new_sprite_frames
		player_animated_sprite_3d.animation = sprite_animation_name
		
		animated_sprite_3d_for_offset.hide()
		player_animated_sprite_3d.show()
		
		player_animated_sprite_3d.play()
	
	_update_material_to_current_texture(player_animated_sprite_3d)
	_update_material_to_current_texture(animated_sprite_3d_for_offset)

func _update_material_to_current_texture(animated_sprite: AnimatedSprite3D):
	var material_sprite: ShaderMaterial = animated_sprite.material_override
	var texture = animated_sprite.sprite_frames.get_frame_texture(animated_sprite.animation, animated_sprite.frame)
	material_sprite.set_shader_parameter("main_texture", texture)

func _update_particle_to_current_sprite():
	var texture = player_animated_sprite_3d.sprite_frames.get_frame_texture(player_animated_sprite_3d.animation, player_animated_sprite_3d.frame)
	var material_dash: ShaderMaterial = dash_effect.material_override
	
	if texture is AtlasTexture:
		var atlas_size: Vector2 = texture.atlas.get_size()
		var region: Rect2 = texture.region

		var uv_offset: Vector2 = region.position / atlas_size
		var uv_scale: Vector2 = region.size / atlas_size

		material_dash.set_shader_parameter("main_texture", texture.atlas)
		material_dash.set_shader_parameter("uv_offset", uv_offset)
		material_dash.set_shader_parameter("uv_scale", uv_scale)
	else:
		material_dash.set_shader_parameter("main_texture", texture)
		material_dash.set_shader_parameter("uv_offset", Vector2.ZERO)
		material_dash.set_shader_parameter("uv_scale", Vector2.ONE)

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
	player_animated_sprite_3d.pause()

func unfreeze():
	_is_freeze = false
	player_animated_sprite_3d.play()

func reset_vibration():
	VibrationManager.stop_joy_vibration(player_id)

func item_will_be_destroy(_item: Item):
	current_picked_item = null
	_item.will_be_destroy.disconnect(item_will_be_destroy)
	_item.has_hit_player.disconnect(_has_hit_other_player)
	
	_kill_current_animation()
	current_item.hide()
	
	VibrationManager.start_joy_vibration(player_id, vibration_force_on_objet_destroy, 0, vibration_duration_on_objet_destroy)

func apply_skin_and_color(selection: PlayerCharacterSelection):
	character_animation = selection.character_texture
	player_animated_sprite_3d.material_override = selection.color_skin.color_shader_3d.duplicate()
	animated_sprite_3d_for_offset.material_override = selection.color_skin.color_shader_3d.duplicate()
	skin = selection.skin
	
	var dash_material: ShaderMaterial = selection.color_skin.color_shader_3d.duplicate()
	dash_material.set_shader_parameter("color_override", Color.WHITE)
	dash_material.set_shader_parameter("blend_delta", 0.5)
	
	dash_effect.material_override = dash_material

func apply_slow(speed_multiplier: float, duration: float):
	if _slow_tween:
		_slow_tween.kill()
		_slow_tween = null
	
	VibrationManager.start_joy_vibration(player_id, 0, vibration_force_on_slow, 0, true)
	
	_slow_tween = create_tween()
	_slow_tween.set_ease(Tween.EASE_IN)
	_slow_tween.set_trans(Tween.TRANS_QUAD)
	_slow_tween.tween_property(self, "_speed_multiplier", speed_multiplier, speed_change_transition)
	_slow_tween.tween_interval(duration)
	_slow_tween.tween_callback(func(): VibrationManager.stop_joy_vibration(player_id))
	_slow_tween.tween_property(self, "_speed_multiplier", 1, speed_change_transition)
	_slow_tween.finished.connect(func(): _slow_tween = null)

func _has_hit_other_player():
	VibrationManager.start_joy_vibration(player_id, vibration_force_on_hit_other_player, 0, vibration_duration_on_hit_other_player)
