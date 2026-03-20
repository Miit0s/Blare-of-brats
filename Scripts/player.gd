extends CharacterBody2D

@export_range(0,3) var device_id: int = 0
@export_category("Basic Movement")
@export var speed: float = 300.0
@export_category("Dash")
@export var dash_speed: float = 1500.0
@export var dash_cooldown: float = 0.5
@export var dash_duration: float = 0.08
var _is_dashing: bool = false
var _dash_can_be_use: bool = true
var _last_direction: Vector2 = Vector2.RIGHT

var _suffix: String = ""

func _ready() -> void:
	_suffix = "_" + str(device_id)

func _physics_process(_delta: float) -> void:
	#Basic movement
	var direction: Vector2 = Input.get_vector("Left" + _suffix, "Right" + _suffix, "Up" + _suffix, "Down" + _suffix)
	
	#Dash
	if Input.is_action_just_pressed("Dash" + _suffix) and _dash_can_be_use:
		dash()

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

func dash():
	_dash_can_be_use = false
	_is_dashing = true
	get_tree().create_timer(dash_cooldown).timeout.connect(func(): _dash_can_be_use = true)
	get_tree().create_timer(dash_duration).timeout.connect(func(): _is_dashing = false)
	
