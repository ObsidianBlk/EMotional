extends Node2D


signal exit_level

func _input(event):
	if event.is_action_pressed("ButtonA"):
		emit_signal("exit_level", null, null, "Level_001.tscn")
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func is_main_menu():
	return true

func get_starting_position():
	return get_node("Player_Start").position

func get_level_music():
	return ""


func _on_AnimPlayer_animation_finished(anim_name):
	set_process_input(true)
