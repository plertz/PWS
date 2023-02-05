extends Node

export (float) var delay = 80.0;
signal auto_save

func _ready():
	var timer = $Timer
	timer.wait_time = delay;

func _on_Timer_timeout():
	emit_signal("auto_save");
