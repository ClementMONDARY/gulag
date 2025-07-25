extends Node3D

# Const
const SPEED = 40.0
var velocity = Vector3.ZERO

@onready var mesh = $MeshInstance3D
@onready var ray = $RayCast3D
@onready var particules = $GPUParticles3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += velocity * delta
	if ray.is_colliding():
		mesh.visible = false
		particules.emitting = true
		ray.enabled = false
		if ray.get_collider().is_in_group("enemy"):
			ray.get_collider().hit()
		await get_tree().create_timer(1.0).timeout
		queue_free()

func set_velocity(target):
	look_at_from_position(position, target)
	velocity = position.direction_to(target) * SPEED

func _on_timer_timeout() -> void:
	queue_free()
