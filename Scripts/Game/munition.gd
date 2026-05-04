extends CharacterBody3D
class_name Munition

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var explosion_particle: GPUParticles3D = $ExplosionParticle

var speed: float = 1
var damage: int = 1
var direction: Vector3 = Vector3.ZERO

var _has_hit: bool = false

func _physics_process(delta: float) -> void:
	if _has_hit: return
	
	var motion = direction.normalized() * speed
	
	var collision: KinematicCollision3D = move_and_collide(motion)
	if collision:
		var collider = collision.get_collider()
		if collider is Player:
			collider.hit(damage, direction)
		
		destroy()

func destroy():
	_has_hit = true
	mesh_instance_3d.hide()
	explosion_particle.emitting = true
	
	await explosion_particle.finished
	queue_free()
