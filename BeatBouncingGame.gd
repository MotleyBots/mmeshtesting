extends Node2D

# Beat-synchronized bouncing particles using MultiMeshInstance2D
class_name BeatBouncingGame

@export var particle_count: int = 100
@export var beat_interval: float = 0.5
@export var bounce_force: float = 200.0
@export var gravity: float = 500.0
@export var box_size: Vector2 = Vector2(800, 600)
@export var particle_size: float = 8.0
@export var particle_color: Color = Color.WHITE
@export var max_velocity: float = 400.0

var multimesh_instance: MultiMeshInstance2D
var particles_data: Array[ParticleData]

class ParticleData:
	var position: Vector2
	var velocity: Vector2
	
	func _init(pos: Vector2, vel: Vector2 = Vector2.ZERO):
		position = pos
		velocity = vel

func _ready():
	setup_multimesh()
	setup_particles()
	
	# Connect to MusicManager beat signal
	if MusicManager:
		MusicManager.beat_detected.connect(trigger_beat)
	
func setup_multimesh():
	# Create MultiMeshInstance2D with colored quads
	multimesh_instance = MultiMeshInstance2D.new()
	add_child(multimesh_instance)
	
	var multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_2D
	multimesh.use_colors = true  # Enable color support
	multimesh.instance_count = particle_count
	
	var quad_mesh = QuadMesh.new()
	quad_mesh.size = Vector2(particle_size, particle_size)
	multimesh.mesh = quad_mesh
	
	multimesh_instance.multimesh = multimesh

func setup_particles():
	# Initialize particles with random positions and velocities
	particles_data.clear()
	for i in range(particle_count):
		var particle_data = ParticleData.new(
			Vector2(randf_range(particle_size, box_size.x - particle_size),
					randf_range(particle_size, box_size.y - particle_size)),
			Vector2(randf_range(-100, 100), randf_range(-100, 100))
		)
		particles_data.append(particle_data)

func _process(delta):
	update_particles(delta)
	update_multimesh()

func trigger_beat():
	# Apply upward bounce force to all particles
	for particle_data in particles_data:
		particle_data.velocity.y -= bounce_force

func update_particles(delta):
	# Update physics for each particle
	for particle_data in particles_data:
		# Apply gravity and update position
		particle_data.velocity.y += gravity * delta
		
		# Limit velocity to max_velocity
		if particle_data.velocity.length() > max_velocity:
			particle_data.velocity = particle_data.velocity.normalized() * max_velocity
		
		particle_data.position += particle_data.velocity * delta
		
		# Handle wall collisions with damping
		handle_wall_collision(particle_data)

func handle_wall_collision(particle_data: ParticleData):
	# Bounce off walls with energy loss
	var half_size = particle_size * 0.5
	
	if particle_data.position.x <= half_size:
		particle_data.position.x = half_size
		particle_data.velocity.x = abs(particle_data.velocity.x) * 0.8
	elif particle_data.position.x >= box_size.x - half_size:
		particle_data.position.x = box_size.x - half_size
		particle_data.velocity.x = -abs(particle_data.velocity.x) * 0.8
	
	if particle_data.position.y <= half_size:
		particle_data.position.y = half_size
		particle_data.velocity.y = abs(particle_data.velocity.y) * 0.8
	elif particle_data.position.y >= box_size.y - half_size:
		particle_data.position.y = box_size.y - half_size
		particle_data.velocity.y = -abs(particle_data.velocity.y) * 0.8

func update_multimesh():
	# Update MultiMesh instance transforms and colors
	var multimesh = multimesh_instance.multimesh
	for i in range(particle_count):
		var particle_data = particles_data[i]
		
		# Set position transform
		var transform = Transform2D().translated(particle_data.position)
		multimesh.set_instance_transform_2d(i, transform)
		
		# Set color
		multimesh.set_instance_color(i, particle_color)

func _draw():
	# Draw boundary box
	draw_rect(Rect2(Vector2.ZERO, box_size), Color.WHITE, false, 2.0)

# External control methods
func set_particle_color(color: Color):
	particle_color = color

func set_bounce_force(force: float):
	bounce_force = force

func set_max_velocity(velocity: float):
	max_velocity = velocity
