extends Control

var gtimer;
export (float) var delay_time_s = 0.1;

func _on_timeout():
	gtimer.queue_free()	
	hide()

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

func crosshair_show():
	add_timer()
	show()
	
