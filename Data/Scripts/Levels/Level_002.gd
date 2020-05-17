extends Node2D

signal exit_level

func get_starting_position():
	return get_node("Player_Start").position

func get_level_music():
	return "Industria.ogg"


func _on_ExitVortex_exit_level(exit, body, next_level):
	emit_signal("exit_level", exit, body, next_level)
