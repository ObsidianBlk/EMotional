extends Node2D

export var next_level:String = ""

signal exit_level;

func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		emit_signal("exit_level", self, body, next_level)
