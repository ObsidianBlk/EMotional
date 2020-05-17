extends Node2D

signal exit_level

func is_main_menu():
	return false

func get_starting_position():
	return get_node("Player_Start").position

func get_level_music():
	return "Fly_1.ogg"

func _on_ExitVortex_exit_level(exit, body, next_level):
	emit_signal("exit_level", exit, body, next_level)
