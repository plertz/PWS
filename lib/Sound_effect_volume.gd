extends AudioStreamPlayer3D

onready var volume_settings = get_tree().get_root().get_node("/root/Main/Audio")

func _ready():
	var volume = (volume_settings.sound_effects_volume / 100) * 80
	if volume == 0:
		unit_size = 0.1
	else: 
		unit_size = 40
	unit_db = volume

