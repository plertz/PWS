extends Control

signal return_main

func _on_Player_menu_open():
	show()

func _on_Player_menu_close():
	hide()


func _on_Continue_pressed():
	Input.action_press("ui_cancel")


func _on_Leave_pressed():
	emit_signal("return_main");
	

func _on_Quit_pressed():
	get_tree().quit()
