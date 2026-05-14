extends MeshInstance3D

@onready var blood_splatter: GPUParticles3D = $BloodSplatter
@onready var terrain_splatter: GPUParticles3D = $TerrainSplatter

var alpha := 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var dup_mat = material_override.duplicate()
	material_override = dup_mat

func init(pos1, pos2):
	var draw_mesh = ImmediateMesh.new()
	mesh = draw_mesh
	draw_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	draw_mesh.surface_add_vertex(pos1)
	draw_mesh.surface_add_vertex(pos2)
	draw_mesh.surface_end()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	alpha -= delta * 3.5
	if alpha <= 0.0:
		alpha = 0.0
	material_override.albedo_color.a = alpha

func trigger_particles(pos, gun_pos, on_enemy):
	if on_enemy:
		blood_splatter.global_position = pos
		blood_splatter.look_at(gun_pos)
		blood_splatter.emitting = true
	else:
		terrain_splatter.global_position = pos
		terrain_splatter.look_at(gun_pos)
		terrain_splatter.emitting = true


func _on_timer_timeout() -> void:
	queue_free()
