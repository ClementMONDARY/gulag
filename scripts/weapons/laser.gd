extends Node3D

var laser_explosion_scene = preload("uid://c4mnmbedxjeyn")

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var ground_zero: Marker3D = $GroundZero

func _ready() -> void:
	var dummy = laser_explosion_scene.instantiate()
	dummy.queue_free()
	animation_player.stop()

func spawn_explosion() -> void:
	var explosion_i = laser_explosion_scene.instantiate()
	add_child(explosion_i)
	explosion_i.global_position = ground_zero.global_position
