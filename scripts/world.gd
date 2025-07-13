extends Node3D

@onready var hit_rect = $UI/ColorRect
@onready var spawns_node = $Map/Spawns
@onready var navigation_region = $Map/NavigationRegion3D

var zombie = load("res://scenes/zombie.tscn")
var instance

func _ready() -> void:
	randomize()

func _process(delta: float) -> void:
	pass

func _on_player_player_hit() -> void:
	hit_rect.set_visible(true)
	await get_tree().create_timer(0.2).timeout
	hit_rect.set_visible(false)

func _get_random_child(parent_node):
	var random_id = randi() % parent_node.get_child_count()
	return parent_node.get_child(random_id)

func _on_zombie_spawn_timer_timeout() -> void:
	var spawn_point = _get_random_child(spawns_node).global_position
	instance = zombie.instantiate()
	instance.position = spawn_point
	navigation_region.add_child(instance)
