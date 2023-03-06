extends Node

var count = 0;

export var audio_tracks = {
	"pistol_shot": preload("res://assets/audio/Pistol.mp3"),
	"rifle_shot": preload("res://assets/audio/Rifle.mp3"),
	"knife": preload("res://assets/audio/Knife.mp3"),
}

export (float) var volume_db = 10;

onready var volume_settings = get_tree().get_root().get_node("/root/Main/Audio")

func _ready():
	var volume = (volume_settings.sound_effects_volume / 100) * 24
	if volume == 0:
		volume = -80
	volume_db = volume

func play_audio(audio_track):
	var Audio_player = AudioStreamPlayer.new()
	Audio_player.stream = audio_tracks[audio_track]
	Audio_player.volume_db = volume_db
	Audio_player.script = preload("res://lib/Delete_sound.gd")
	
	Audio_player.name = str(count)
	add_child(Audio_player)
	count += 1
