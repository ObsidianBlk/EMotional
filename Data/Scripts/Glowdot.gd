tool
extends Sprite

const TRANS = Tween.TRANS_LINEAR
const EASE = Tween.EASE_IN_OUT

export var pulse_color:Color setget _set_pulse_color, _get_pulse_color
export var pulse_in_time:float = 0.5
export var pulse_out_time:float = 0.5
export var pulse_in:float = 0.1
export var pulse_out:float = 0.9
export var pulse_offset:float = 0.1 setget _set_pulse_offset, _get_pulse_offset

var _running = false


func _camp(v, o_min, o_max):
	# Reduces v (clamped to 0 and 1) to the values between o_min and o_max
	return o_min + ((o_max - o_min) * clamp(v, 0.0, 1.0))

func _ramp(v, f_min, f_max):
	# Expands v, spreading the values between f_min and f_max to be between 0 and 1.
	if f_min == f_max:
		return f_min
		
	return clamp((v - f_min) / (f_max - f_min), 0.0, 1.0)

func _set_pulse_offset(v):
	material.set_shader_param("fade_offset", _camp(v, 0.1, 0.5))

func _get_pulse_offset():
	return _ramp(material.get_shader_param("fade_offset"), 0.1, 0.5)

func _set_pulse_color(c):
	material.set_shader_param("primary_color", c)

func _get_pulse_color():
	return material.get_shader_param("primary_color")

func _ready():
	material.set_shader_param("primary_color", pulse_color)

func start():
	_running = true
	_on_PulseOut_timeout()

func stop():
	$PulseOut.stop()
	$PulseIn.stop()
	_running = false

func _interpolate_to(v, t):
	$Pulse.interpolate_property(self, "pulse_offset", self.pulse_offset, v, t, TRANS, EASE)
	$Pulse.start()


func _on_PulseIn_timeout():
	if _running:
		#print(self.get_name(), " Pulse Out Time: ", $PulseOut.wait_time)
		$PulseIn.stop()
		if _get_pulse_offset() == pulse_in:
			$PulseOut.wait_time = pulse_out_time
		else:
			$PulseOut.wait_time = (1.0 - ((_get_pulse_offset() - pulse_in) / (pulse_out / pulse_in))) * pulse_out_time
		_interpolate_to(pulse_out, $PulseOut.wait_time)
		$PulseOut.start()


func _on_PulseOut_timeout():
	if _running:
		#print(self.get_name(), " Pulse In Time: ", $PulseOut.wait_time)
		$PulseOut.stop()
		if _get_pulse_offset() == pulse_out:
			$PulseIn.wait_time = pulse_in_time
		else:
			# Adjust time due to current offset.
			$PulseIn.wait_time = (_get_pulse_offset() - pulse_in) / (pulse_out / pulse_in) * pulse_in_time
		_interpolate_to(pulse_in, $PulseIn.wait_time)
		$PulseIn.start()
