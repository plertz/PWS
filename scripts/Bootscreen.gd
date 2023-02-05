extends Control

var gtimer;
export (int) var delay_time_s = 3;

signal main_menu_ready;

func _on_timeout():
	gtimer.queue_free()	
	emit_signal("main_menu_ready");

func set_timer():
	gtimer = get_node("gtimer")
	gtimer.wait_time = delay_time_s;
	gtimer.one_shot = true;
	gtimer.connect("timeout", self, "_on_timeout");
	gtimer.start()

func add_timer():
	var timer = Timer.new();
	timer.name = "gtimer";
	add_child(timer);
	set_timer();

func _ready():
	add_timer();
	OS.window_borderless = true;
	var win_size = OS.get_real_window_size();
	var size = OS.get_screen_size();
	var pos = size / 2;
	pos.x -= (win_size.x /2);
	pos.y -= (win_size.y /2);
	OS.window_position = pos;
	


