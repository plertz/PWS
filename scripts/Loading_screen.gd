extends Control

var gtimer;
export (float) var delay_time_s = 0.5;

signal start

func _on_timeout():
	gtimer.queue_free()
	emit_signal("start");

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
	var menu_size = OS.get_real_window_size()
	rect_size = menu_size;

func _on_Loading_screen_visibility_changed():
	if(visible):
		add_timer()
	return
