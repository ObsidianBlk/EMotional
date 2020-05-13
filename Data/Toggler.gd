extends Node2D




func _on_Area2D_body_entered(body):
	var bs = get_parent().get_node("BladeSaw")
	bs.active = !bs.active
