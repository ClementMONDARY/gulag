extends Node3D

# Const
const SPEED = 25.0
var velocity = Vector3.ZERO

var rocket_explosion = preload("res://scenes/rocket_explosion.tscn")
var instance

@onready var ray = $RayCast3D
@onready var particules = $GPUParticles3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += velocity * delta
	if ray.is_colliding():
		ray.enabled = false
		particules.emitting = false
		instance = rocket_explosion.instantiate()
		get_parent().add_child(instance)
		instance.global_position = ray.get_collision_point()
		await get_tree().create_timer(0.1).timeout
		queue_free()

func set_velocity(target):
	look_at_from_position(position, target)
	velocity = position.direction_to(target) * SPEED

func _on_timer_timeout() -> void:
	instance = rocket_explosion.instantiate()
	instance.global_position = global_position
	get_parent().add_child(instance)
	queue_free()
