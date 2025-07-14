extends CharacterBody3D

var player = null
var state_machine
var health = 6

const SPEED = 4.0
const ATTACK_RANGE = 2.5

@export var player_path := "/root/World/Map/NavigationRegion3D/Player"

@onready var nav_agent = $NavigationAgent3D
@onready var anim_tree = $AnimationTree

signal zombie_hit

func _ready() -> void:
	player = get_node(player_path)
	state_machine = anim_tree.get("parameters/playback")


func _process(delta: float) -> void:
	velocity = Vector3.ZERO
	
	match state_machine.get_current_node():
		"Run":
			# Navigation
			nav_agent.set_target_position(player.global_transform.origin)
			var next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
			look_at(Vector3(global_position.x + velocity.x, global_position.y, global_position.z + velocity.z), Vector3.UP)
			rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10.0)
		"Attack":
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	
	# Animations
	anim_tree.set("parameters/conditions/attack", _target_in_range())
	anim_tree.set("parameters/conditions/run", not _target_in_range())
	
	move_and_slide()

func _target_in_range(): 
	return global_position.distance_to(player.global_position) <= ATTACK_RANGE

func _hit_finished():
	if global_position.distance_to(player.global_position) <= ATTACK_RANGE + 1.0:
		var dir = global_position.direction_to(player.global_position)
		player.hit(dir)


func _on_area_3d_body_part_hit(dam: Variant) -> void:
	health -= dam
	zombie_hit.emit()
	if health <= 0.0:
		anim_tree.set("parameters/conditions/die", true)
		await anim_tree.animation_finished
		queue_free()
