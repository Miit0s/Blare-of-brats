@tool
extends RigidBody2D
class_name Item

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var sprite_2d: Sprite2D = $Sprite2D

@export var throw_force: float = 20
@export var collision_size: float = 10:
	set(new_value):
		collision_size = new_value
		_ready()
@export_category("Instance")
@export var object_texture: Texture2D:
	set(new_value):
		object_texture = new_value
		_ready()
@export var object_texture_size: float = 1:
	set(new_value):
		object_texture_size = new_value
		_ready()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var collision_shape: CircleShape2D = collision_shape_2d.shape
	collision_shape.radius = collision_size / 2
	
	sprite_2d.texture = object_texture
	sprite_2d.scale = Vector2(object_texture_size, object_texture_size)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func throw(direction: Vector2):
	apply_central_impulse(direction.normalized() * throw_force)
