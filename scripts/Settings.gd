extends Control

onready var sound_effects = $ColorRect/Sound_effects
onready var sound_track = $ColorRect/Sound_track

onready var back_btn = $ColorRect/Back 
onready var apply_btn = $ColorRect/Apply

onready var volume_settings = get_tree().get_root().get_node("/root/Main/Audio")


var sound_track_volume = 40
var sound_effects_volume = 25

func _ready():
	OS.window_borderless = true;	
	OS.window_position = Vector2(0, 0);
	var size = OS.get_screen_size()
	OS.window_size = size;
	var menu_size = OS.get_real_window_size()
	rect_size = menu_size;

	sound_track_volume = volume_settings.sound_track_volume
	sound_effects_volume = volume_settings.sound_effects_volume

	sound_effects.value = sound_effects_volume
	sound_track.value = sound_track_volume

	back_btn.connect("pressed", self, "_back_pressed")
	apply_btn.connect("pressed", self, "_apply_pressed")



func _back_pressed():
	set_defaults()
	hide()

func _apply_pressed():
	sound_effects_volume = sound_effects.value
	sound_track_volume = sound_track.value
	get_tree().call_group("soundtrack", "change_volume", sound_track_volume, sound_effects_volume)

	hide()


func set_defaults():
	sound_effects.value = sound_effects_volume
	sound_track.value = sound_track_volume
