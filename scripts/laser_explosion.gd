extends Node3D

@onready var area_3d: Area3D = $Area3D

func _process(delta: float) -> void:
	var overlapping_areas = area_3d.get_overlapping_areas()
	for area in overlapping_areas:
		if area.is_in_group("enemy"):
			area.hit()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()
