extends Node

# Music Beat Manager - Autoload for handling music and beat detection
class_name MusicBeatManager

signal beat_detected

@export var bpm: float = 120.0  # Beats per minute
@export var auto_play: bool = true
@export var beat_offset: float = 0.0  # Offset in seconds to align first beat
@export var audio_player: AudioStreamPlayer
var beat_interval: float
var last_beat_time: float = 0.0
var is_playing: bool = false

func _ready():
	calculate_beat_interval()
	setup_audio()
	
	if auto_play:
		play_music()

func setup_audio():
	# Configure audio player if it exists
	if audio_player:
		audio_player.finished.connect(_on_music_finished)

func calculate_beat_interval():
	# Convert BPM to seconds between beats
	beat_interval = 60.0 / bpm

func _process(delta):
	if is_playing and audio_player.playing:
		check_for_beat()

func check_for_beat():
	# Get current playback position
	var current_time = audio_player.get_playback_position()
	
	# Calculate where we should be in the beat cycle
	var adjusted_time = current_time - beat_offset
	var current_beat = floor(adjusted_time / beat_interval)
	var expected_beat_time = (current_beat + 1) * beat_interval + beat_offset
	
	print("checking beat")
	
	# Check if we've passed the next beat time
	if current_time >= expected_beat_time and current_time > last_beat_time:
		last_beat_time = expected_beat_time
		beat_detected.emit()

# Public methods for external control
func load_music(audio_stream: AudioStream):
	audio_player.stream = audio_stream

func play_music():
	if audio_player.stream:
		audio_player.play()
		is_playing = true
		last_beat_time = 0.0

func stop_music():
	audio_player.stop()
	is_playing = false
	last_beat_time = 0.0

func pause_music():
	audio_player.stream_paused = true
	is_playing = false

func resume_music():
	audio_player.stream_paused = false
	is_playing = true

func set_bpm(new_bpm: float):
	bpm = new_bpm
	calculate_beat_interval()
	last_beat_time = 0.0  # Reset beat tracking

func set_beat_offset(offset: float):
	beat_offset = offset
	last_beat_time = 0.0  # Reset beat tracking

func set_volume(volume_db: float):
	audio_player.volume_db = volume_db

func get_playback_position() -> float:
	return audio_player.get_playback_position()

func is_music_playing() -> bool:
	return is_playing and audio_player.playing

# Private callback
func _on_music_finished():
	is_playing = false
	last_beat_time = 0.0
