extends Control

onready var soundtrack = get_node("/root/Main/Audio")

onready var settings = $Settings
onready var settings_btn = $ButtonContainer/Settings

signal start
signal new_game

func _ready():
	OS.window_borderless = true;	
	OS.window_position = Vector2(0, 0);
	var size = OS.get_screen_size()
	OS.window_size = size;
	var menu_size = OS.get_real_window_size()
	rect_size = menu_size;
	soundtrack.play_audio("main_menu")
	settings_btn.connect("pressed", self, "_on_settings_pressed")

func _on_settings_pressed():
	settings.show()


func _on_Start_pressed():
	emit_signal("start")


func _on_New_game_pressed():
	emit_signal("new_game");
