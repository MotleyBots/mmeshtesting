extends Control

# Test scene controller for beat bouncing game
class_name TestScene

@onready var game: BeatBouncingGame
@onready var ui_panel: VBoxContainer
@onready var color_picker: ColorPicker
@onready var beat_slider: HSlider
@onready var force_slider: HSlider
@onready var count_slider: HSlider

func _ready():
	setup_game()
	setup_ui()

func setup_game():
	# Create and configure the main game
	game = BeatBouncingGame.new()
	game.particle_count = 50
	game.beat_interval = 0.6
	game.bounce_force = 300.0
	game.box_size = Vector2(400, 400)
	game.particle_size = 6.0
	game.particle_color = Color.RED
	
	# Position game in center of screen
	game.position = Vector2(50, 50)
	add_child(game)

func setup_ui():
	# Create UI panel
	ui_panel = VBoxContainer.new()
	ui_panel.position = Vector2(800, 50)
	ui_panel.custom_minimum_size = Vector2(200, 400)
	add_child(ui_panel)
	
	# Color control
	create_label("Particle Color:")
	color_picker = ColorPicker.new()
	color_picker.color = game.particle_color
	color_picker.custom_minimum_size = Vector2(180, 200)
	color_picker.color_changed.connect(_on_color_changed)
	ui_panel.add_child(color_picker)
	
	# Beat interval control
	create_label("Beat Interval (seconds):")
	beat_slider = create_slider(0.1, 2.0, game.beat_interval, _on_beat_changed)
	
	# Bounce force control
	create_label("Bounce Force:")
	force_slider = create_slider(50.0, 500.0, game.bounce_force, _on_force_changed)
	
	# Particle count control
	create_label("Particle Count:")
	count_slider = create_slider(10.0, 200.0, game.particle_count, _on_count_changed)

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

# UI callback functions
func _on_color_changed(color: Color):
	game.set_particle_color(color)

func _on_beat_changed(value: float):
	game.set_beat_interval(value)

func _on_force_changed(value: float):
	game.set_bounce_force(value)

func _on_count_changed(value: float):
	var new_count = int(value)
	game.particle_count = new_count
	game.setup_particles()  # Reinitialize with new count
