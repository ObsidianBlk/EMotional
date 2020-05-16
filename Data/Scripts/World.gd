extends Node2D

var _timer = 0.0
var _level_running = true

var _level_node = null

func get_hours():
	return floor(_timer / 3600.0)

func get_minutes():
	return floor(fmod((_timer / 60), 60.0))

func get_seconds():
	return floor(fmod(_timer, 60.0))


func load_and_play_music(src):
	var fn = "res://Data/Sound/Music/" + src
	if File.new().file_exists(fn):
		$Music.stream = load(fn)
		$Music.play()

func load_level(src):
	_level_running = false
	get_node("Player").hide()
	var lvl = get_node("lvl")
	if _level_node != null:
		lvl.remove_child(_level_node)
		_level_node.call_deferred("free")
		_level_node = null
	var lvlres = load("res://Data/Scenes/Levels/" + src)
	if lvlres:
		_level_node = lvlres.instance()
		lvl.add_child(_level_node)
		load_and_play_music(_level_node.get_level_music())
		reset()


func reset():
	if _level_node:
		get_tree().paused = true
		var p = get_node("Player")
		if _level_node.has_method("get_starting_position"):
			p.position = _level_node.get_starting_position()
		else:
			p.position = Vector2.ZERO
		p.reset()
		p.show()
		_timer = 0.0
		get_tree().paused = false

func pause(enable = true):
	if get_tree().paused != enable:
		_level_running = !enable
		get_tree().paused = enable


func _ready():
	set_physics_process(true)
	load_level("Level_001.tscn")
	#var ps = get_node("Level_00/Player_Start")
	#get_node("Player").position = get_node("Level_TestSite").get_starting_position()
	#get_node("Player").show()

func _physics_process(delta):
	if _level_running:
		_timer += delta


func _on_PM_Quit_pressed():
	get_tree().quit()
