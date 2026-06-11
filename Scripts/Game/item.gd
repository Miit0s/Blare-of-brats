extends RigidBody3D
class_name Item

@onready var item_visual: Sprite3D = $ItemVisual
@onready var item_animation: AnimatedSprite3D = $VisualAnchor/ItemAnimation
@onready var explosion_particle: GPUParticles3D = $ExplosionParticle
@onready var trail_renderer_3d: TrailRenderer3D = $TrailRenderer3D
@onready var visual_anchor: Marker3D = $VisualAnchor

@onready var circle_spawn_particle: GPUParticles3D = $CircleSpawnParticle
@onready var other_spawn_particle: GPUParticles3D = $OtherSpawnParticle
@onready var gpu_trail_3d: GPUTrail3D = $VisualAnchor/GPUTrail3D

@export_category("Attack")
@export var attack_speed: float = 0.5
@export var damage: float = 1
@export var reverse_attack_dash: bool = false

@export_category("Throw")
@export var throw_force: float = 30.0
@export var throw_damage: float = 5.0
@export var throw_max_distance: float = 16.5

@export_category("Sound")
@export var sound_on_attack: float = 1
@export var sound_on_throw: float = 2
@export var sound_on_break: float = 5
@export var attack_sound: WwiseEvent
### If true, sound will be added to the game sound bar for every attack
@export var sound_always_made: bool = false

@export_category("Lifetime")
@export var durability: int = 5
@export var break_on_throw: bool = true
var current_durability: int = 0:
	set(new_value):
		current_durability = new_value
		has_loose_durability.emit(new_value)

@export_category("Instance")
@export var collision_shape_3d: CollisionShape3D

@export var attack_collision_area: Area3D
@export var attack_collision_shape_3d: CollisionShape3D

@export var hit_particle_prefab: PackedScene

##The id of the player currently holding the item. It goes from 1 to 4, and is -1 if there is no one owning it
var owner_player: int = -1

##The minimal speed the item should have. When the speed is under this threshold, the speed is set to zero
var minimal_speed: float = 2
var has_been_throw: bool = false
var has_been_drop: bool = false

var is_attacking: bool = false
var is_already_pick: bool = false

var camera: Camera3D = null

var _attacked_players: Array[Player]

var _attack_direction: Vector3 = Vector3.ZERO
var _throw_direction: Vector3 = Vector3.ZERO

var _throw_start_point: Vector3 = Vector3.ZERO
##The id of the player that throwed the object. Used to avoid colliding with the object at throw
var _throw_by: int = -1

signal sound_made(value: float, global_position: Vector3)

signal has_loose_durability()
signal will_be_destroy(item: Item)

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
	camera = get_viewport().get_camera_3d()
	current_durability = durability
	
	circle_spawn_particle.emitting = true
	other_spawn_particle.emitting = true

func _physics_process(_delta: float) -> void:
	if not has_been_throw: return
	
	if global_position.distance_to(_throw_start_point) > throw_max_distance:
		destroy()

func _process(_delta: float) -> void:
	if not has_been_throw and not is_attacking: return
	
	var attack_area_overlapping_bodies: Array = attack_collision_area.get_overlapping_bodies()
	if attack_area_overlapping_bodies.is_empty(): return
	for body in attack_area_overlapping_bodies:
		var player_hit: Player = body
		if player_hit.player_id != owner_player and player_hit.player_id != _throw_by and _attacked_players.count(player_hit) == 0:
			if has_been_throw:
				_collide_with_player(player_hit)
			elif is_attacking:
				_attack_player(player_hit)

func throw(direction: Vector3):
	_throw_direction = direction
	_throw_start_point = global_position
	set_collision_layer_value(4, true)
	set_collision_mask_value(4, true)
	
	_throw_by = owner_player
	has_been_throw = true
	is_already_pick = false
	owner_player = -1
	
	apply_central_impulse(direction.normalized() * throw_force)
	sound_made.emit(sound_on_throw, global_position)
	
	trail_renderer_3d.show()
	rotation = Vector3.ZERO
	item_animation.hide()
	item_visual.show()
	
	_force_check_collision_detection()

func attack(direction: Vector3):
	_attack_direction = direction
	is_attacking = true
	
	_perform_attack(direction)
	
	if attack_sound:
		attack_sound.post(self)
	if sound_always_made:
		sound_made.emit(sound_on_attack, global_position)
	
	await get_tree().create_timer(attack_speed).timeout
	is_attacking = false
	_attacked_players.clear()
	
	if current_durability <= 0: destroy()

func _perform_attack(_direction: Vector3):
	push_error("Perform attack should always be override")

func destroy():
	collision_layer = 0
	collision_mask = 0
	freeze = true
	
	attack_collision_area.monitoring = false
	attack_collision_area.set_deferred("monitorable", false)
	
	has_been_throw = false
	is_attacking = false
	
	linear_velocity = Vector3.ZERO
	
	sound_made.emit(sound_on_break, global_position)
	will_be_destroy.emit(self)
	item_animation.hide()
	item_visual.hide()
	trail_renderer_3d.hide()
	explosion_particle.emitting = true
	
	await explosion_particle.finished
	
	queue_free()

func item_picked_up(player_id: int):
	owner_player = player_id
	is_already_pick = true
	
	item_visual.hide()
	item_animation.show()

func drop():
	has_been_drop = true
	is_already_pick = false
	owner_player = -1
	
	rotation = Vector3.ZERO
	item_animation.hide()
	item_visual.show()
	
	await get_tree().create_timer(0.1).timeout
	
	has_been_drop = false

func _get_hit_point(target: Node3D) -> Vector3:
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(self.global_position, target.global_position)
	query.exclude = [self]
	var result: Dictionary = space_state.intersect_ray(query)
	
	if result.is_empty():
		return Vector3.ZERO
	
	return result.position

func _add_hit_effect(target: Node3D):
	var hit_point: Vector3 = _get_hit_point(target)
	if hit_point == Vector3.ZERO: return
	
	var hit_particle: GPUParticles3D = hit_particle_prefab.instantiate()
	add_child(hit_particle)
	
	hit_particle.global_position = hit_point
	hit_particle.finished.connect(hit_particle.queue_free)
	
	hit_particle.emitting = true

func _attack_player(player_hit: Player):
	if not sound_always_made:
		sound_made.emit(sound_on_attack, global_position)
	
	_attacked_players.append(player_hit)
	player_hit.hit(damage, _attack_direction)
	_add_hit_effect(player_hit)

func _collide_with_player(player_hit: Player):
	_attacked_players.append(player_hit)
	player_hit.hit(throw_damage, _throw_direction)
	destroy()

func cancel_animation():
	is_attacking = false
	
	gpu_trail_3d.hide()
	gpu_trail_3d.length = 0
	
	item_animation.stop()

func _on_body_entered(body: Node):
	if has_been_throw and body is not Player:
		destroy()

func _force_check_collision_detection():
	if get_colliding_bodies().is_empty(): return
	
	if has_been_throw:
		destroy()
