@tool
class_name TrackingSpot extends Node3D

@export var target : Node3D
@export_range(0,300) var distance : float = 50
@export_range(1,10) var angle : float = 10
@export var color : Color = Color.ORANGE
@export var enabled : bool
@export var create_a_temp_target: bool = false
@export var temp_target_lifetime: float = 10

@export var mesh : MeshInstance3D
@export var light : SpotLight3D

func _ready() -> void:
	if target and create_a_temp_target:
		target.tree_exiting.connect(_on_target_exit.bind(target.global_position))

func _process(_delta: float) -> void:
	if target and target.is_inside_tree():
		if target.global_position.z == 0 and target.global_position.x == 0:
			look_at(target.global_position)
		else:
			look_at(target.global_position, Vector3.UP)
	light.spot_angle = angle
	light.spot_range = distance
	var cylinder : CylinderMesh = mesh.mesh
	cylinder.height = distance
	mesh.position.z = -distance/2
	cylinder.bottom_radius = distance * tan(deg_to_rad(angle))
	var mat : StandardMaterial3D = cylinder.material
	mat.albedo_color = color
	light.light_color = color

func _on_target_exit(exit_position: Vector3):
	if not is_inside_tree(): return
	if not is_multiplayer_authority(): return
	
	var empty_node_target: Node3D = Node3D.new()
	empty_node_target.position = exit_position
	add_child(empty_node_target)
	self.target = empty_node_target
	
	await get_tree().create_timer(temp_target_lifetime).timeout
	
	empty_node_target.queue_free()
	self.queue_free()
