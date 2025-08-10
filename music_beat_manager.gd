extends Node

# Simple Music Manager - Just plays music
class_name MusicBeatManager

@export var audio_player: AudioStreamPlayer

var time_elapsed: float = 0.0

func _ready():
	pass

func _process(delta):
	time_elapsed += delta

func get_volume() -> float:
	# Simple approach: just return a sine wave for testing
	return (sin(time_elapsed * 2.0) + 1.0) * 0.5

func load_music(audio_stream: AudioStream):
	if audio_player:
		audio_player.stream = audio_stream

func play_music():
	if audio_player and audio_player.stream:
		audio_player.play()

func stop_music():
	if audio_player:
		audio_player.stop()

func pause_music():
	if audio_player:
		audio_player.stream_paused = true

func resume_music():
	if audio_player:
		audio_player.stream_paused = false

func set_volume(volume_db: float):
	if audio_player:
		audio_player.volume_db = volume_db

func is_music_playing() -> bool:
	return audio_player and audio_player.playing
