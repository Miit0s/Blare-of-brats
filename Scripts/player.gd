extends CharacterBody2D

@export var device_id: int = 0
@export_category("Basic Movement")
@export var speed: float = 300.0
@export var deadzone: float = 0.2
@export_category("Dash")
@export var dash_speed: float = 1500.0
@export var dash_cooldown: float = 0.5
@export var dash_duration: float = 0.08
var _is_dashing: bool = false
var _dash_can_be_use: bool = true
var _last_direction: Vector2 = Vector2.RIGHT

func _physics_process(delta: float) -> void:
	#Basic movement
	var direction: Vector2 = Vector2(
		Input.get_joy_axis(device_id, JOY_AXIS_LEFT_X) - Input.get_joy_axis(device_id, JOY_AXIS_RIGHT_X),
		Input.get_joy_axis(device_id, JOY_AXIS_LEFT_Y) - Input.get_joy_axis(device_id, JOY_AXIS_RIGHT_Y)
	).limit_length()
	
	if direction.x >= -deadzone and direction.x <= deadzone : direction.x = 0
	if direction.y >= -deadzone and direction.y <= deadzone : direction.y = 0
	
	#Dash
	if Input.is_action_just_pressed("Dash") and _dash_can_be_use:
		dash()

	if _is_dashing:
		if direction: velocity = direction * dash_speed
		else: velocity = _last_direction * dash_speed
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
	
