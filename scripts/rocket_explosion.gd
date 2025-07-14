extends Node3D

@onready var area_3d: Area3D = $Area3D

func _ready() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	var overlapping_areas = area_3d.get_overlapping_areas()
	for area in overlapping_areas:
		if area.is_in_group("enemy"):
			area.hit()
	await  get_tree().create_timer(3.0).timeout
	queue_free()


func _process(delta: float) -> void:
	pass
