extends Node

var count = 0;

export var audio_tracks = {
	"pistol_shot": preload("res://assets/audio/Pistol.mp3"),
	"rifle_shot": preload("res://assets/audio/Rifle.mp3"),
	"knife": preload("res://assets/audio/Knife.mp3")
}

export (float) var volume_db = 40;

func play_audio(audio_track):
	var Audio_player = AudioStreamPlayer.new()
	Audio_player.stream = audio_tracks[audio_track]
	Audio_player.volume_db = volume_db
	Audio_player.script = preload("res://lib/Delete_sound.gd")
	
	# var len_arr = get_children().size()
	Audio_player.name = str(count)
	add_child(Audio_player)
	count += 1
