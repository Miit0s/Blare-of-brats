extends Control
class_name RoundStartUI

@onready var ready_label: Label = $Ready
@onready var go: Label = $Go

@export_category("Tween")
@export var ready_transtion_center_duration: float = 0.3
@export var ready_wait_duration: float = 0.7
@export var go_transition_duration: float = 0.27
@export var go_wait_duration: float = 0.64

signal start_round
signal animation_finish

func start_animation():
	ready_label.position.x = -ready_label.size.x
	ready_label.show()
	
	go.scale = Vector2.ZERO
	go.show()
	
	var ready_label_center: Vector2 = Vector2((size.x / 2) - (ready_label.size.x / 2), ready_label.position.y)
	
	var start_animation_tween: Tween = create_tween()
	start_animation_tween.set_ease(Tween.EASE_OUT)
	start_animation_tween.set_trans(Tween.TRANS_CUBIC)
	start_animation_tween.tween_property(ready_label, "position", ready_label_center, ready_transtion_center_duration)
	start_animation_tween.tween_interval(ready_wait_duration)
	start_animation_tween.tween_callback(ready_label.hide)
	start_animation_tween.set_trans(Tween.TRANS_BACK)
	start_animation_tween.tween_property(go, "scale", Vector2.ONE, go_transition_duration)
	start_animation_tween.tween_callback(start_round.emit)
	start_animation_tween.tween_interval(go_wait_duration)
	
	await start_animation_tween.finished
	
	animation_finish.emit()
	
	go.hide()
