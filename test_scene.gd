extends Control

# Test scene controller for simple bouncing game
class_name TestScene

@onready var game: SimpleBouncingGame
@onready var ui_panel: VBoxContainer
@onready var velocity_slider: HSlider
@onready var count_slider: HSlider
@onready var bounce_slider: HSlider
@onready var health_slider: HSlider

func _ready():
	setup_game()
	setup_ui()

func setup_game():
	# Create and configure the main game
	game = SimpleBouncingGame.new()
	game.particle_count = 50
	game.gravity = 300.0
	game.gravity_enabled = true
	game.box_size = Vector2(700, 500)
	game.particle_size = 6.0
	game.particle_color = Color.CYAN
	game.max_velocity = 400.0
	game.bounce_factor = 1.0
	#game.emissive_strength = 2.0
	#game.multimesh_instance.self_modulate = Color(10,10,10,1)
	
	# Position game in center of screen
	game.position = Vector2(50, 50)
	add_child(game)

func setup_ui():
	# Create UI panel
	ui_panel = VBoxContainer.new()
	ui_panel.position = Vector2(800, 50)
	ui_panel.custom_minimum_size = Vector2(200, 300)
	add_child(ui_panel)
	
	# Max velocity control
	create_label("Max Velocity:")
	velocity_slider = create_slider(100.0, 800.0, game.max_velocity, _on_velocity_changed)
	
	# Bounce factor control
	create_label("Bounce Factor:")
	bounce_slider = create_slider(0.0, 1.0, game.bounce_factor, _on_bounce_changed)
	
	# Health control
	create_label("Health:")
	health_slider = create_slider(0.0, float(game.get_max_health()), float(game.get_health()), _on_health_changed)
	
	# Particle count control
	create_label("Particle Count:")
	count_slider = create_slider(10.0, 200.0, game.particle_count, _on_count_changed)
	
	# Gravity toggle
	create_label("Gravity:")
	create_gravity_toggle()

func create_label(text: String) -> Label:
	# Helper to create UI labels
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 14)
	ui_panel.add_child(label)
	return label

func create_slider(min_val: float, max_val: float, current_val: float, callback: Callable) -> HSlider:
	# Helper to create UI sliders with labels
	var slider = HSlider.new()
	slider.min_value = min_val
	slider.max_value = max_val
	slider.value = current_val
	slider.step = (max_val - min_val) / 100.0
	slider.value_changed.connect(callback)
	ui_panel.add_child(slider)
	
	# Add value label
	var value_label = Label.new()
	value_label.text = str(current_val)
	value_label.add_theme_font_size_override("font_size", 12)
	slider.value_changed.connect(func(value): value_label.text = "%.2f" % value)
	ui_panel.add_child(value_label)
	
	return slider

func create_gravity_toggle():
	# Create gravity toggle button
	var gravity_button = Button.new()
	gravity_button.text = "Gravity: ON"
	gravity_button.toggle_mode = true
	gravity_button.button_pressed = game.gravity_enabled
	gravity_button.toggled.connect(_on_gravity_toggled)
	ui_panel.add_child(gravity_button)

# UI callback functions
func _on_velocity_changed(value: float):
	game.set_max_velocity(value)

func _on_bounce_changed(value: float):
	game.set_bounce_factor(value)

func _on_health_changed(value: float):
	game.set_health(int(value))

func _on_count_changed(value: float):
	var new_count = int(value)
	game.set_particle_count(new_count)
	
	# Update health slider range when particle count changes
	health_slider.max_value = float(game.get_max_health())
	health_slider.value = float(game.get_health())

func _on_gravity_toggled(pressed: bool):
	game.set_gravity_enabled(pressed)
	# Update button text
	var button = ui_panel.get_children().filter(func(child): return child is Button and child.toggle_mode)[0]
	button.text = "Gravity: ON" if pressed else "Gravity: OFF"
