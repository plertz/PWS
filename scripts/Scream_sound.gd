extends AudioStreamPlayer

onready var timer = get_node("Timer")

var time_stamps = [0.0, 2.0, 4.22, 6.14]

onready var volume_settings = get_tree().get_root().get_node("/root/Main/Audio")

func _ready():
	var volume = (volume_settings.sound_effects_volume / 100) * 24
	if volume == 0:
		volume = -80
	volume_db = volume

	timer.connect("timeout", self, "_on_timeout")

func play_scream():
	if playing:
		return
	var index = (randi() % 4)
	var time_stamp = time_stamps[index]
	var dtime = 0
	if index == 3:
		dtime = 4
	else:
		dtime = time_stamps[index + 1] - time_stamp
	timer.wait_time = dtime;
	timer.start()
	play(time_stamp)

func _on_timeout():
	stop()
