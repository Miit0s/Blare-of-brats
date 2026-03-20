extends CharacterBody2D

@export var device_id: int = 0
@export var speed: float = 300.0
#@export var friction: float = 500.0
@export var deadzone: float = 0.2

func _physics_process(delta: float) -> void:
	var direction: Vector2 = Vector2(
		Input.get_joy_axis(device_id, JOY_AXIS_LEFT_X) - Input.get_joy_axis(device_id, JOY_AXIS_RIGHT_X),
		Input.get_joy_axis(device_id, JOY_AXIS_LEFT_Y) - Input.get_joy_axis(device_id, JOY_AXIS_RIGHT_Y)
	).limit_length()
	
	if direction.x >= -deadzone and direction.x <= deadzone : direction.x = 0
	if direction.y >= -deadzone and direction.y <= deadzone : direction.y = 0

	if direction:
		velocity = direction * speed
	else:
		velocity.x = 0
		velocity.y = 0
	#	velocity.x = move_toward(velocity.x, 0.0, friction * delta)
	#	velocity.y = move_toward(velocity.y, 0.0, friction * delta)

	move_and_slide()
