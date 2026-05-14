extends Node3D

@onready var laser_animation_player: AnimationPlayer = $Starship/Ship_1/Laser/AnimationPlayer

func shoot_laser() -> void:
	laser_animation_player.play("shoot")
