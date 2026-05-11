@icon("uid://be3u7amlues51")
@tool
class_name TrailRenderer3D
extends LineRenderer3D

@export var trail_point_lifetime: float = 1.0

var previous_position: Vector3

func _ready() -> void:
	super._ready()
	previous_position = global_position
	points.clear()

func _process(delta: float) -> void:
	super._process(delta)
		
	if previous_position.is_equal_approx(global_position): return
	
	points.push_front(global_position)
	get_tree().create_timer(trail_point_lifetime).timeout.connect(
		func(): 
			points.pop_back()
			if points.is_empty() and mesh is ImmediateMesh:
				var immediate_mesh: ImmediateMesh = mesh
				immediate_mesh.clear_surfaces()
	)
	
	previous_position = global_position
