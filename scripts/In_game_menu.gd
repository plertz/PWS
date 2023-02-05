extends Control

signal return_main

func _on_Player_menu_open():
	show()

func _on_Player_menu_close():
	hide()


func _on_Continue_pressed():
	hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_Leave_pressed():
	emit_signal("return_main");
	

func _on_Quit_pressed():
	get_tree().quit()
