tool
extends Node2D

export var pulse_color:Color = Color(1.0, 0.8, 0.0, 1.0) setget _set_color


func _set_color(c):
	pulse_color = c
	$Dot.pulse_color = c
	$Dot21.pulse_color = c
	$Dot22.pulse_color = c
	$Dot31.pulse_color = c
	$Dot32.pulse_color = c

func _ready():
	set_color(pulse_color)
	$Dot.start()
	$Dot21.start()
	$Dot22.start()
	$Dot31.start()
	$Dot32.start()

func set_color(c):
	_set_color(c)

