@tool
extends Sprite3D
class_name Sprite3DWithBloom

@export_range(0.0, 16.0, 0.1) var bloom_force: float = 0.0: 
	set(new_value):
		bloom_force = new_value
		bloom_value_change(new_value)


func _ready() -> void:
	if not material_override:
		material_override = StandardMaterial3D.new()
		material_override.emission_enabled = true
		material_override.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material_override.cull_mode = BaseMaterial3D.CULL_DISABLED
	
	texture_changed.connect(new_texture_apply)
	bloom_value_change(bloom_force)
	new_texture_apply()


func bloom_value_change(new_value: float):
	var material: StandardMaterial3D = material_override
	material.emission_energy_multiplier = new_value
	
	material_override = material

func new_texture_apply():
	var material: StandardMaterial3D = material_override
	material.albedo_texture = texture
	material.emission_texture = texture
	
	material_override = material
