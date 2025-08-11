extends Node2D

# Simple bouncing particles using MultiMeshInstance2D
class_name SimpleBouncingGame

@export var particle_count: int = 100
@export var gravity: float = 500.0
@export var gravity_enabled: bool = true
@export var box_size: Vector2 = Vector2(800, 600)
@export var particle_size: float = 8.0
@export var particle_color: Color = Color.WHITE
@export var max_velocity: float = 400.0
@export var bounce_factor: float = 0.8

var max_health: int
var health: int

# Health-based colors
var color1: Color = Color.GREEN     # Green (healthy)
var color2: Color = Color.YELLOW    # Yellow (warning)
var color3: Color = Color.RED       # Red (critical)

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
	update_health_system()

func _process(delta):
	manage_health()
	update_particles(delta)
	update_multimesh()

func setup_multimesh():
	# Create MultiMeshInstance2D with colored quads
	multimesh_instance = MultiMeshInstance2D.new()
	add_child(multimesh_instance)
	
	var multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_2D
	multimesh.use_colors = true
	multimesh.instance_count = particle_count
	
	var quad_mesh = QuadMesh.new()
	quad_mesh.size = Vector2(particle_size, particle_size)
	
	# Apply material to mesh
	multimesh.mesh = quad_mesh
	
	multimesh_instance.multimesh = multimesh
	
	#Glow
	#multimesh_instance.self_modulate = Color(10,10,10,1)

func setup_particles():
	# Initialize particles with random positions and velocities
	particles_data.clear()
	
	# Update multimesh instance count
	if multimesh_instance and multimesh_instance.multimesh:
		multimesh_instance.multimesh.instance_count = particle_count
	
	for i in range(particle_count):
		var particle_data = ParticleData.new(
			Vector2(randf_range(particle_size, box_size.x - particle_size),
					randf_range(particle_size, box_size.y - particle_size)),
			Vector2(randf_range(-100, 100), randf_range(-100, 100))
		)
		particles_data.append(particle_data)
	
	# Update health system when particle count changes
	update_health_system()

func manage_health() -> void:
	if health < particle_count:
		set_particle_count(health)

func set_particle_count(new_count: int):
	if new_count == particle_count:
		return
		
	var old_count = particle_count
	particle_count = new_count
	
	# Update multimesh instance count
	if multimesh_instance and multimesh_instance.multimesh:
		multimesh_instance.multimesh.instance_count = particle_count
	
	if new_count > old_count:
		# Adding particles - preserve existing ones and add new ones
		for i in range(old_count, new_count):
			var particle_data = ParticleData.new(
				Vector2(randf_range(particle_size, box_size.x - particle_size),
						randf_range(particle_size, box_size.y - particle_size)),
				Vector2(randf_range(-100, 100), randf_range(-100, 100))
			)
			particles_data.append(particle_data)
	elif new_count < old_count:
		# Removing particles - preserve the first new_count particles
		particles_data.resize(new_count)
	
	# Update health system
	update_health_system()

func update_particles(delta):
	# Update physics for each particle
	for particle_data in particles_data:
		# Apply gravity if enabled
		if gravity_enabled:
			particle_data.velocity.y += gravity * delta
		
		# Limit velocity to max_velocity
		if particle_data.velocity.length() > max_velocity:
			particle_data.velocity = particle_data.velocity.normalized() * max_velocity
		
		particle_data.position += particle_data.velocity * delta
		
		# Handle wall collisions with damping
		handle_wall_collision(particle_data)

func handle_wall_collision(particle_data: ParticleData):
	# Bounce off walls with configurable energy loss
	var half_size = particle_size * 0.5
	
	if particle_data.position.x <= half_size:
		particle_data.position.x = half_size
		particle_data.velocity.x = abs(particle_data.velocity.x) * bounce_factor
	elif particle_data.position.x >= box_size.x - half_size:
		particle_data.position.x = box_size.x - half_size
		particle_data.velocity.x = -abs(particle_data.velocity.x) * bounce_factor
	
	if particle_data.position.y <= half_size:
		particle_data.position.y = half_size
		particle_data.velocity.y = abs(particle_data.velocity.y) * bounce_factor
	elif particle_data.position.y >= box_size.y - half_size:
		particle_data.position.y = box_size.y - half_size
		particle_data.velocity.y = -abs(particle_data.velocity.y) * bounce_factor

func update_multimesh():
	# Update MultiMesh instance transforms and colors
	var multimesh = multimesh_instance.multimesh
	var actual_count = min(particle_count, particles_data.size())
	
	for i in range(actual_count):
		var particle_data = particles_data[i]
		
		# Set position transform
		var transform = Transform2D().translated(particle_data.position)
		multimesh.set_instance_transform_2d(i, transform)
		
		# Set color based on health
		var particle_color = get_particle_color(i)
		multimesh.set_instance_color(i, particle_color)

func get_particle_color(particle_index: int) -> Color:
	# Calculate color distribution based on health
	if health == max_health:
		return color1
	
	var health_ratio = float(health) / float(max_health)
	
	if health_ratio > 0.6666:
		# Top third: mix of green and yellow
		var unhealthy_particles = particle_count - (health - (max_health * 2 / 3)) / (max_health / (3 * particle_count))
		if particle_index < (particle_count - unhealthy_particles):
			return color1  # Green
		else:
			return color2  # Yellow
	elif health_ratio > 0.3333:
		# Middle third: mix of yellow and red
		var healthy_particles = (health - (max_health / 3)) / (max_health / (3 * particle_count))
		if particle_index < healthy_particles:
			return color2  # Yellow
		else:
			return color3  # Red
	else:
		# Bottom third: mostly red with some yellow
		var yellow_particles = health / (max_health / (3 * particle_count))
		if particle_index < yellow_particles:
			return color2  # Yellow
		else:
			return color3  # Red

func set_self_modulate_intensity(intensity: float):
	if multimesh_instance:
		multimesh_instance.self_modulate = Color(intensity, intensity, intensity, 1.0)

func reduce_self_modulate_over_time(delta: float, reduction_rate: float = 2.0):
	if multimesh_instance:
		var current = multimesh_instance.self_modulate
		var max_channel = max(current.r, max(current.g, current.b))
		
		if max_channel > 1.0:
			var new_intensity = max_channel - (reduction_rate * delta)
			new_intensity = max(new_intensity, 1.0)  # Don't go below 1.0
			multimesh_instance.self_modulate = Color(new_intensity, new_intensity, new_intensity, 1.0)

func update_health_system():
	# Update max health and clamp current health
	max_health = 3 * particle_count
	health = clamp(health, 0, max_health)
	
	# If health hasn't been initialized, set to max
	if health == 0:
		health = max_health

func _draw():
	# Draw boundary box
	draw_rect(Rect2(Vector2.ZERO, box_size), Color.WHITE, false, 2.0)

# External control methods
func set_particle_color(color: Color):
	particle_color = color

func set_max_velocity(velocity: float):
	max_velocity = velocity

func set_gravity_enabled(enabled: bool):
	gravity_enabled = enabled

func set_bounce_factor(factor: float):
	bounce_factor = factor

func set_health(new_health: int):
	health = clamp(new_health, 0, max_health)

func get_health() -> int:
	return health

func get_max_health() -> int:
	return max_health
