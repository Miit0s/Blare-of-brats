@tool
extends RigidBody3D
class_name Item

@onready var sprite_3d: Sprite3D = $Sprite3D
@onready var explosion_particle: GPUParticles3D = $ExplosionParticle
@onready var trail_renderer_3d: TrailRenderer3D = $TrailRenderer3D
@onready var trail_pivot: Node3D = $TrailPivot

@onready var circle_spawn_particle: GPUParticles3D = $CircleSpawnParticle
@onready var other_spawn_particle: GPUParticles3D = $OtherSpawnParticle
@onready var gpu_trail_3d: GPUTrail3D = $TrailPivot/GPUTrail3D

@export_category("Type")
@export var distance: bool = false

@export_category("Melee Attack")
@export var attack_shape: Shape3D:
	set(new_value):
		if attack_shape: attack_shape.changed.disconnect(_init_item_instance)
		
		attack_shape = new_value
		new_value.changed.connect(_init_item_instance)
		_init_item_instance()

@export_category("Distance Attack")
@export var munition_prefab: PackedScene
@export var munition_speed: float = 0.1

@export_category("Attack")
@export var attack_speed: float = 0.5
@export var damage: float = 1

@export_category("Throw")
@export var throw_force: float = 20.0
@export var throw_damage: float = 5.0
@export var throw_max_distance: float = 20.0

@export_category("Sound")
@export var sound_on_attack: float = 1
@export var sound_on_throw: float = 2
@export var sound_on_break: float = 5
@export var attack_sound: WwiseEvent

@export_category("Lifetime")
@export var durability: int = 5
@export var break_on_throw: bool = true
var current_durability: int = 0:
	set(new_value):
		current_durability = new_value
		has_loose_durability.emit(new_value)

@export_category("Instance")
@export var object_texture: Texture2D:
	set(new_value):
		object_texture = new_value
		_init_item_instance()
@export var object_texture_size: float = 1:
	set(new_value):
		object_texture_size = new_value
		_init_item_instance()

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
var is_melee_attacking: bool = false
var is_already_pick: bool = false

var _attacked_players: Array[Player]

var _attack_direction: Vector3 = Vector3.ZERO
var _throw_direction: Vector3 = Vector3.ZERO

var _throw_start_point: Vector3 = Vector3.ZERO

signal sound_made(value: float)

signal has_loose_durability()
signal will_be_destroy(item: Item)

func _ready() -> void:
	current_durability = durability
	
	circle_spawn_particle.emitting = true
	other_spawn_particle.emitting = true
	
	_init_item_instance()

func _init_item_instance():
	if not is_inside_tree(): return
	
	sprite_3d.texture = object_texture
	sprite_3d.scale = Vector3(object_texture_size, object_texture_size, object_texture_size)
	attack_collision_shape_3d.shape = attack_shape

func _physics_process(_delta: float) -> void:
	if not has_been_throw: return
	
	if global_position.distance_to(_throw_start_point) > throw_max_distance:
		destroy()
	
	if linear_velocity.length() < minimal_speed:
		destroy()

func _process(_delta: float) -> void:
	if not has_been_throw and not is_melee_attacking: return
	
	var attack_area_overlapping_bodies: Array = attack_collision_area.get_overlapping_bodies()
	if attack_area_overlapping_bodies.is_empty(): return
	for body in attack_area_overlapping_bodies:
		var player_hit: Player = body
		if player_hit.player_id != owner_player and _attacked_players.count(player_hit) == 0:
			if has_been_throw:
				_collide_with_player(player_hit)
			elif is_melee_attacking:
				_attack_player(player_hit)

func throw(direction: Vector3):
	_throw_direction = direction
	_throw_start_point = global_position
	set_collision_layer_value(4, true)
	set_collision_mask_value(4, true)
	apply_central_impulse(direction.normalized() * throw_force)
	sound_made.emit(sound_on_throw)
	
	await get_tree().create_timer(0.1).timeout
	
	has_been_throw = true
	is_already_pick = false
	owner_player = -1
	trail_renderer_3d.show()

func attack(direction: Vector3):
	_attack_direction = direction
	is_attacking = true
	
	if distance : _distance_attack()
	else: _melee_attack()
	
	if attack_sound:
		attack_sound.post(self)
	
	
	await get_tree().create_timer(attack_speed).timeout
	is_attacking = false
	
	if current_durability <= 0: destroy()

func _melee_attack():
	is_melee_attacking = true
	gpu_trail_3d.show()
	gpu_trail_3d.length = 100
	
	await get_tree().create_timer(attack_speed).timeout
	is_melee_attacking = false
	_attacked_players = []
	gpu_trail_3d.hide()
	gpu_trail_3d.length = 0

func _distance_attack():
	current_durability -= 1
	
	var new_munition: Munition = munition_prefab.instantiate()
	new_munition.direction = _attack_direction
	new_munition.damage = damage
	new_munition.speed = munition_speed
	new_munition.position = global_position
	
	add_child(new_munition)
	
	sound_made.emit(sound_on_attack)

func destroy():
	collision_layer = 0
	collision_mask = 0
	freeze = true
	
	attack_collision_area.monitoring = false
	attack_collision_area.monitorable = false
	
	has_been_throw = false
	is_melee_attacking = false
	
	linear_velocity = Vector3.ZERO
	
	sound_made.emit(sound_on_break)
	will_be_destroy.emit(self)
	sprite_3d.hide()
	trail_renderer_3d.hide()
	explosion_particle.emitting = true
	
	await explosion_particle.finished
	
	queue_free()

func item_picked_up(player_id: int):
	owner_player = player_id
	is_already_pick = true

func drop():
	has_been_drop = true
	is_already_pick = false
	owner_player = -1
	
	await get_tree().create_timer(0.1).timeout
	
	has_been_drop = false

func slash_look_at(target_position: Vector3):
	var fixed_target_pos: Vector3 = Vector3(target_position.x, trail_pivot.global_position.y, target_position.z)
	trail_pivot.look_at(fixed_target_pos)

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
	current_durability -= 1
	sound_made.emit(sound_on_attack)
	
	_attacked_players.append(player_hit)
	player_hit.hit(damage, _attack_direction)
	_add_hit_effect(player_hit)

func _collide_with_player(player_hit: Player):
	_attacked_players.append(player_hit)
	player_hit.hit(throw_damage, _throw_direction)
	destroy()

func cancel_animation():
	is_attacking = false
	is_melee_attacking = false
	
	gpu_trail_3d.hide()
	gpu_trail_3d.length = 0
