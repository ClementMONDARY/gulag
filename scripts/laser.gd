extends Node3D

const LASER_EXPLOSION = preload("uid://c4mnmbedxjeyn")

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var ground_zero: Marker3D = $GroundZero

func _ready() -> void:
	animation_player.stop()

func spawn_explosion() -> void:
	var explosion_i = LASER_EXPLOSION.instantiate()
	add_child(explosion_i)
	explosion_i.global_position = ground_zero.global_position
