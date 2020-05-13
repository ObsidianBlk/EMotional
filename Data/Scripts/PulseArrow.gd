extends Node2D

export var pulse_color:Color = Color(1.0, 0.8, 0.0, 1.0)


func _ready():
	$Dot.pulse_color = pulse_color
	$Dot.start()
	$Dot21.pulse_color = pulse_color
	$Dot21.start()
	$Dot22.pulse_color = pulse_color	
	$Dot22.start()
	$Dot31.pulse_color = pulse_color
	$Dot31.start()
	$Dot32.pulse_color = pulse_color
	$Dot32.start()

