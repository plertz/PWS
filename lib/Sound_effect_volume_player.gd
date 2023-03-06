extends AudioStreamPlayer

onready var volume_settings = get_tree().get_root().get_node("/root/Main/Audio")

func _ready():
	var volume = (volume_settings.sound_effects_volume / 100) * 24
	if volume == 0:
		volume = -80
	volume_db = volume
