extends Node

var _timer: Timer
var _high_priority_vibration_playing: bool = false

## Emit when the last send vibration has ended
signal vibration_ended

func _ready() -> void:
	_timer = Timer.new()
	_timer.autostart = false
	_timer.one_shot = true
	_timer.timeout.connect(vibration_ended.emit)
	
	add_child(_timer)

func start_joy_vibration(device: int, weak_magnitude: float, strong_magnitude: float, duration: float = 0, high_priority: bool = false):
	if GameOptions.saved_options.activate_controller_vibration and not _high_priority_vibration_playing:
		Input.start_joy_vibration(device, clamp(weak_magnitude, 0, 1), clamp(strong_magnitude, 0, 1), duration)
		
		if high_priority:
			_high_priority_vibration_playing = true
		
		if duration > 0:
			_timer.stop()
			_timer.wait_time = duration
			_timer.start()
			
			if _high_priority_vibration_playing: vibration_ended.connect(func(): _high_priority_vibration_playing = false, ConnectFlags.CONNECT_ONE_SHOT)

func stop_joy_vibration(device: int):
	Input.stop_joy_vibration(device)
	_high_priority_vibration_playing = false
