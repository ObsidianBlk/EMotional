extends CanvasLayer

onready var _agg_bar = get_node("PlayerUI/MoodBars/Aggression/Bar/Progress")
onready var _agg_bar_tween = get_node("PlayerUI/MoodBars/Aggression/Bar/Progress/Tween")
onready var _need_bar = get_node("PlayerUI/MoodBars/Neediness/Bar/Progress")
onready var _need_bar_tween = get_node("PlayerUI/MoodBars/Neediness/Bar/Progress/Tween")
onready var _content_bar = get_node("PlayerUI/MoodBars/Contentment/Bar/Progress")
onready var _content_bar_tween = get_node("PlayerUI/MoodBars/Contentment/Bar/Progress/Tween")

onready var _nrg_bar = get_node("PlayerUI/NRG/Bar/Progress")
onready var _nrg_bar_tween = get_node("PlayerUI/NRG/Bar/Progress/Tween")

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)
	_agg_bar.max_value = 100.0
	_agg_bar.value = 0.0
	_need_bar.max_value = 100.0
	_need_bar.value = 0.0
	_content_bar.max_value = 100.0
	_content_bar.value = 0.0
	
	_nrg_bar.max_value = get_node("../Player").max_energy
	_nrg_bar.value = get_node("../Player").get_current_energy()


func _process(delta):
	UpdateMoodBars()
	UpdateTimer()

func _toClockString(v):
	if v < 10:
		return "0" + String(v)
	return String(v)

func UpdateTimer():
	var p = get_parent()
	var h = p.get_hours()
	var m = p.get_minutes()
	var s = p.get_seconds()
	get_node("Timer/TimeText").text = _toClockString(h) + ":" + _toClockString(m) + ":" + _toClockString(s)

func UpdateMoodBars():
	var p = get_node("../Player")
	var mc = p.get_mood().get_mood_color()
	_agg_bar_tween.interpolate_property(_agg_bar, "value", _agg_bar.value, mc.r * 100, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	_agg_bar_tween.start()
	_need_bar_tween.interpolate_property(_need_bar, "value", _need_bar.value, mc.g * 100, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	_need_bar_tween.start()
	_content_bar_tween.interpolate_property(_content_bar, "value", _content_bar.value, mc.b * 100, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	_content_bar_tween.start()
	
	_nrg_bar_tween.interpolate_property(_nrg_bar, "value", _nrg_bar.value, p.get_current_energy(), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	_nrg_bar_tween.start()
