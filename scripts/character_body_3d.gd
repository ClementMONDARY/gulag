extends CharacterBody3D

var speed
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.003
const HIT_STAGGER = 8.0

# Head Movement
const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var t_bob = 0.0

# FOV Variables
const BASE_FOV = 75.0
const FOV_MULTIPLIER = 1.5

# Signals
signal player_hit

var bullet = load("res://scenes/bullet.tscn")
var bullet_trail = load("res://scenes/bullet_trail.tscn")
var instance

enum weapons {
	RIFLES,
	MACHINEGUN
}
var weapon = weapons.MACHINEGUN
var can_shoot = true
@onready var weapon_switching_anim = $Head/Camera3D/WeaponSwitching

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var aim_ray = $Head/Camera3D/AimRay
@onready var aim_rayend = $Head/Camera3D/AimRayend

# Guns
@onready var rifle_anim = $"Head/Camera3D/Steampunk Rifle/AnimationPlayer"
@onready var rifle_barrel = $"Head/Camera3D/Steampunk Rifle/RayCast3D"
@onready var rifle_anim_secondary = $"Head/Camera3D/Steampunk Rifle Secondary/AnimationPlayer"
@onready var rifle_barrel_secondary = $"Head/Camera3D/Steampunk Rifle Secondary/RayCast3D"
@onready var machinegun_anim = $"Head/Camera3D/Steampunk Machingun/AnimationPlayer"
@onready var machingun_barrel = $"Head/Camera3D/Steampunk Machingun/Meshes/Barrel"

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
	
	# Head bobbing effect
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.position = _headbob(t_bob)
	
	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_MULTIPLIER * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	# Gun logic
	if Input.is_action_pressed("shoot") and can_shoot:
		match weapon:
			weapons.MACHINEGUN:
				_shoot_machinegun()
			weapons.RIFLES:
				_shoot_rifles()
	
	# Weapon Switching
	if Input.is_action_just_pressed("switch_weapon"):
		var next_weapon = (weapon + 1) % weapons.size()
		_raise_weapon(next_weapon)
		
	
	move_and_slide()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	var prev_y = sin((time - get_physics_process_delta_time()) * velocity.length() * float(is_on_floor()) * BOB_FREQ) * BOB_AMP
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	
	# Play footstep sound when headbob reaches lowest point
	if prev_y > pos.y and pos.y <= -BOB_AMP * 0.8 and is_on_floor() and velocity.length() > 0.1:
		AudioManager.create_3d_audio_at_location_with_culling(global_position, SoundEffect.SOUND_EFFECT_TYPE.ON_PLAYER_WALK)
	
	return pos

func hit(dir):
	player_hit.emit()
	velocity += dir * HIT_STAGGER

func _shoot_rifles():
	if !rifle_anim.is_playing():
		rifle_anim.play("Shoot")
		AudioManager.create_3d_audio_at_location_with_culling(rifle_barrel.global_position, SoundEffect.SOUND_EFFECT_TYPE.ON_RIFLES_SHOOT)
		instance = bullet.instantiate()
		instance.position = rifle_barrel.global_position
		instance.transform.basis = rifle_barrel.global_transform.basis
		if aim_ray.is_colliding():
			instance.set_velocity(aim_ray.get_collision_point())
		else:
			instance.set_velocity(aim_rayend.global_position)
		get_parent().add_child(instance)
	if !rifle_anim_secondary.is_playing():
		rifle_anim_secondary.play("Shoot")
		AudioManager.create_3d_audio_at_location_with_culling(rifle_barrel_secondary.global_position, SoundEffect.SOUND_EFFECT_TYPE.ON_RIFLES_SHOOT)
		instance = bullet.instantiate()
		instance.position = rifle_barrel_secondary.global_position
		instance.transform.basis = rifle_barrel_secondary.global_transform.basis
		if aim_ray.is_colliding():
			instance.set_velocity(aim_ray.get_collision_point())
		else:
			instance.set_velocity(aim_rayend.global_position)
		get_parent().add_child(instance)

func _shoot_machinegun():
	if !machinegun_anim.is_playing():
		machinegun_anim.play("Shoot")
		AudioManager.create_3d_audio_at_location_with_culling(machingun_barrel.global_position, SoundEffect.SOUND_EFFECT_TYPE.ON_MG_SHOOT)
		instance = bullet_trail.instantiate()
		if aim_ray.is_colliding():
			instance.init(machingun_barrel.global_position, aim_ray.get_collision_point())
			get_parent().add_child(instance)
			if aim_ray.get_collider().is_in_group("enemy"):
				aim_ray.get_collider().hit()
				instance.trigger_particles(aim_ray.get_collision_point(), machingun_barrel.global_position, true)
			else:
				instance.trigger_particles(aim_ray.get_collision_point(), machingun_barrel.global_position, false)
		else:
			instance.init(machingun_barrel.global_position, aim_rayend.global_position)

func _lower_weapon():
	match weapon:
		weapons.MACHINEGUN:
			weapon_switching_anim.play("LowerMG")
		weapons.RIFLES:
			weapon_switching_anim.play("LowerRifles")

func _raise_weapon(new_weapon):
	can_shoot = false
	_lower_weapon()
	await weapon_switching_anim.animation_finished
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.ON_WEAPON_SWITCH)
	match new_weapon:
		weapons.MACHINEGUN:
			weapon_switching_anim.play_backwards("LowerMG")
		weapons.RIFLES:
			weapon_switching_anim.play_backwards("LowerRifles")
	weapon = new_weapon
	can_shoot = true
