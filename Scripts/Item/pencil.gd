@tool
extends Item

@export var slash_arc_angle: float = 120

func _perform_attack(_direction: Vector3):
	gpu_trail_3d.show()
	gpu_trail_3d.length = 100
	
	var start_rotation = visual_anchor.rotation
	
	visual_anchor.rotation.y -= deg_to_rad(slash_arc_angle / 2)
	var final_rotation: Vector3 = visual_anchor.rotation
	final_rotation.y += deg_to_rad(slash_arc_angle)
	
	var rotation_tween: Tween = create_tween()
	rotation_tween.set_ease(Tween.EASE_OUT)
	rotation_tween.set_trans(Tween.TRANS_CUBIC)
	rotation_tween.tween_property(visual_anchor, "rotation", final_rotation, attack_speed)
	rotation_tween.tween_property(visual_anchor, "rotation", start_rotation, 0)
	
	await get_tree().create_timer(attack_speed).timeout
	_attacked_players = []
	gpu_trail_3d.hide()
	gpu_trail_3d.length = 0

func _process(_delta: float) -> void:
	super._process(_delta)
