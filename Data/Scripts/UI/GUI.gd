extends CanvasLayer

onready var _agg_bar = get_node("PlayerUI/MoodBars/Aggression/Bar/Progress")
onready var _agg_bar_tween = get_node("PlayerUI/MoodBars/Aggression/Bar/Progress/Tween")
onready var _need_bar = get_node("PlayerUI/MoodBars/Neediness/Bar/Progress")
onready var _need_bar_tween = get_node("PlayerUI/MoodBars/Neediness/Bar/Progress/Tween")
onready var _content_bar = get_node("PlayerUI/MoodBars/Contentment/Bar/Progress")
onready var _content_bar_tween = get_node("PlayerUI/MoodBars/Contentment/Bar/Progress/Tween")

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)
	_agg_bar.max_value = 100.0
	_agg_bar.value = 0.0
	_need_bar.max_value = 100.0
	_need_bar.value = 0.0
	_content_bar.max_value = 100.0
	_content_bar.value = 0.0


func _process(delta):
	UpdateMoodBars()

func UpdateMoodBars():
	var mc = get_node("../Player").get_mood().get_mood_color()
	_agg_bar_tween.interpolate_property(_agg_bar, "value", _agg_bar.value, mc.r * 100, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	_agg_bar_tween.start()
	_need_bar_tween.interpolate_property(_need_bar, "value", _need_bar.value, mc.g * 100, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	_need_bar_tween.start()
	_content_bar_tween.interpolate_property(_content_bar, "value", _content_bar.value, mc.b * 100, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	_content_bar_tween.start()
