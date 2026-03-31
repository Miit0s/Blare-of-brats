@tool
extends RigidBody2D
class_name Item

@onready var sprite_2d: Sprite2D = $Sprite2D

@export var throw_force: float = 20
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
@export var attack_duration: float = 0.5

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

func _process(_delta: float) -> void:
	if is_attacking:
		for bodies: Player in attack_collision_area.get_overlapping_bodies():
			if bodies.device_id == owner_player: continue
			bodies.hit()

func _physics_process(_delta: float) -> void:
	if not has_been_throw: return
	
	if linear_velocity.length() < minimal_speed:
		linear_velocity = Vector2.ZERO
		has_been_throw = false

func throw(direction: Vector2):
	apply_central_impulse(direction.normalized() * throw_force)
	await get_tree().create_timer(0.1).timeout
	has_been_throw = true
	is_already_pick = false

func attack():
	is_attacking = true
	await get_tree().create_timer(attack_duration).timeout
	is_attacking = false
