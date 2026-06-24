extends Control
class_name MenuStartScreen

@onready var video_stream_player: VideoStreamPlayer = $SubViewport/VideoStreamPlayer

@export var start_anim_sound: WwiseEvent

func _ready() -> void:
	if GameOptions.have_launch_game:
		queue_free()
		return
	
	video_stream_player.play()
	await get_tree().create_timer(0.1).timeout
	video_stream_player.paused = true

func play_transtion_and_destroy():
	video_stream_player.paused = false
	start_anim_sound.post(self)
	await video_stream_player.finished
	queue_free()
