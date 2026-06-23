@tool
class_name TrackingSpot extends Node3D

@export var target : Node3D
@export_range(0,300) var distance : float = 50
@export_range(1,10) var angle : float = 10
@export_range(0,10) var start_radius: float = 1.0
@export_range(0,10) var end_radius: float = 5.0
@export var use_given_end_radius: bool = false
@export var color: Color = Color.ORANGE
@export var enabled: bool
@export var create_a_temp_target: bool = false
@export var temp_target_lifetime: float = 10

@export var mesh : MeshInstance3D
@export var light : SpotLight3D

func _ready() -> void:
	if target and create_a_temp_target:
		target.tree_exiting.connect(_on_target_exit.bind(target.global_position))
	
	_update_objet_with_new_parameters()

func _physics_process(_delta: float) -> void:
	if target and target.is_inside_tree():
		if target.global_position.z == 0 and target.global_position.x == 0:
			look_at(target.global_position)
		else:
			look_at(target.global_position, Vector3.UP)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_update_objet_with_new_parameters()

func _update_objet_with_new_parameters():
	light.spot_angle = angle
	light.spot_range = distance
	light.light_color = color
	
	var cylinder : CylinderMesh = mesh.mesh
	cylinder.height = distance
	mesh.position.z = -distance/2
	cylinder.top_radius = start_radius
	cylinder.bottom_radius = distance * tan(deg_to_rad(angle)) if not use_given_end_radius else end_radius
	
	var cylinder_material : StandardMaterial3D = cylinder.material
	cylinder_material.albedo_color = color

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
