extends Node

onready var splayer = $Soundtrack
onready var timer = $Timer

var status_on = true

var sound_track_volume = 40
var sound_effects_volume = 25.0

export var audio_tracks = {
	"main_menu": preload("res://assets/audio/Main_menu_Lava_Assault.mp3"),
	"game": preload("res://assets/audio/Overworld_Lava_Assault.mp3"),
	"boss": preload("res://assets/audio/Boss_theme_Lava_Assault.mp3")
}

func play_audio(source):
	if status_on:
		splayer.stream = audio_tracks[source]
		splayer.play()

func play_random():
	var random_float = randf()
	if random_float < 0.6:
		play_audio("game")
	else:
		play_audio("boss")

func _ready():
	add_to_group("soundtrack")
	splayer.connect("finished", self, "_on_finished")
	timer.connect("timeout", self, "_on_timeout")

func _on_finished ():
	timer.wait_time = randi() % 11 + 10
	timer.start()

func _on_timeout():
	play_random()

func change_volume(volume, effect_volume):
	volume = volume / 100 * 24
	if volume == 0:
		splayer.stop()
		status_on = false;
		sound_track_volume = volume
	else:
		status_on = true;
		splayer.volume_db = volume
		sound_track_volume = volume
		splayer.play()
	
	sound_effects_volume = effect_volume
	print("sound effect volume", effect_volume)

