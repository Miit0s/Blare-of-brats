@tool
extends RigidBody2D
class_name Item

@onready var sprite_2d: Sprite2D = $Sprite2D

@export var collision_size: float = 10:
	set(new_value):
		collision_size = new_value
		_init_item_instance()

@export_category("Attack")
@export var attack_shape: Shape2D:
	set(new_value):
		if attack_shape: attack_shape.changed.disconnect(_init_item_instance)
		
		attack_shape = new_value
		new_value.changed.connect(_init_item_instance)
		_init_item_instance()
@export var attack_speed: float = 0.5
@export var damage: int = 1

@export_category("Throw")
@export var throw_force: float = 20
@export var throw_damage: int = 5

@export_category("Sound")
@export var sound_on_attack: int = 1
@export var sound_on_throw: int = 2
@export var sound_on_break: int = 10

@export_category("Lifetime")
@export var nb_use_before_break: int = 20
@export var break_on_throw: bool = true
var _nb_time_used: int = 0

@export_category("Instance")
@export var object_texture: Texture2D:
	set(new_value):
		object_texture = new_value
		_init_item_instance()
@export var object_texture_size: float = 1:
	set(new_value):
		object_texture_size = new_value
		_init_item_instance()

@export var collision_shape_2d: CollisionShape2D

@export var attack_collision_area: Area2D
@export var attack_collision_shape_2d: CollisionShape2D

##The id of the player currently holding the item. It goes from 1 to 4, and is -1 if there is no one owning it
var owner_player: int = -1

##The minimal speed the item should have. When the speed is under this threshold, the speed is set to zero
var minimal_speed: float = 50
var has_been_throw: bool = false

var is_attacking: bool = false
var is_already_pick: bool = false

signal sound_made(value: int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_init_item_instance()

func _init_item_instance():
	if not is_inside_tree(): return
	
	var collision_shape: CircleShape2D = collision_shape_2d.shape
	collision_shape.radius = collision_size / 2
	
	sprite_2d.texture = object_texture
	sprite_2d.scale = Vector2(object_texture_size, object_texture_size)
	attack_collision_shape_2d.shape = attack_shape

func _physics_process(_delta: float) -> void:
	if not has_been_throw: return
	
	if linear_velocity.length() < minimal_speed:
		destroy()
		linear_velocity = Vector2.ZERO
		has_been_throw = false

func _on_attack_collision_area_body_entered(body: Node2D) -> void:
	var player_hit: Player = body
	if player_hit.player_id != owner_player:
		if has_been_throw:
			player_hit.hit(throw_damage)
			destroy()
		elif is_attacking:
			player_hit.hit(damage)

func throw(direction: Vector2):
	apply_central_impulse(direction.normalized() * throw_force)
	sound_made.emit(sound_on_throw)
	await get_tree().create_timer(0.1).timeout
	has_been_throw = true
	is_already_pick = false
	owner_player = -1

func attack():
	is_attacking = true
	_nb_time_used += 1
	sound_made.emit(sound_on_attack)
	
	await get_tree().create_timer(attack_speed).timeout
	is_attacking = false
	
	if _nb_time_used >= nb_use_before_break: destroy()

func destroy():
	sound_made.emit(sound_on_break)
	queue_free()

func item_picked_up(player_id: int):
	owner_player = player_id
	is_already_pick = true
