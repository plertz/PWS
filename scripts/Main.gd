extends Node

var Bootscreen = preload("res://scenes/Bootscreen.tscn").instance()
var Main_menu = preload("res://scenes/Main_menu.tscn").instance()
onready var Loading_screen = get_node("Loading_screen");
var Game;
var bootscreen;
var main_menu
var return_main;
var in_game_menu;


func switch_game(resource):
	get_node("Loading_screen").hide();
	add_child(resource.instance())
	in_game_menu = $World/Player/HUD/Menu
	in_game_menu.connect("return_main", self, "_return_main");
	
func loading():
	Game = ResourceLoader.load_interactive("res://scenes/World.tscn");	
	while OS.get_ticks_msec() < OS.get_ticks_msec() + 1000:
		var err = Game.poll()

		if err == ERR_FILE_EOF: 
			var resource = Game.get_resource()
			Game = null
			switch_game(resource)
			break

func _return_main():
	get_node("World").queue_free()
	load_menu();

func _on_game_started():
	main_menu.queue_free()
	Loading_screen.show()
	return;

func _on_Loading_screen_visibility_changed():
	if(Loading_screen):
		loading()
	return;

func load_menu():
	add_child(preload("res://scenes/Main_menu.tscn").instance());
	main_menu = get_node("Main_menu");
	main_menu.connect("start", self, "_on_game_started")
	return;

func _delete_bootscreen():
	get_node("/root/Main/Bootscreen").queue_free()
	load_menu()
	return;

func _return_to_menu():
	pass

func _ready():
	add_child(Bootscreen);
	bootscreen = get_node("Bootscreen")
	bootscreen.connect("main_menu_ready", self, "_delete_bootscreen");
	return;

func _on_Loading_screen_start():
	loading()
