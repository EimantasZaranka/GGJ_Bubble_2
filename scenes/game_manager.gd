extends Node

var score = 0
@onready var header = $"../Headeris"
@onready var points_text = header.get_node("PointsText")
@onready var timer_label = header.get_node("time_text")

@onready var game_timer = $GameTimer

var time_left: int = 300

func _ready():
	# Start the timer and connect the timeout signal
	game_timer.start(time_left)
	#game_timer.connect("timeout", self, "_on_timer_timeout")
	game_timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	# Optional: Start a countdown display
	update_timer_display()

func _process(delta: float):
	# Update the time_left variable
	if game_timer.time_left > 0:
		time_left = int(game_timer.time_left)
		update_timer_display()

func update_timer_display():
	# Update the UI to show the countdown (if you have a Label node for display)
	#var timer_label = $TimerLabel  # Replace with the path to your Label node
	timer_label.text = str(time_left)


func _on_timer_timeout():
	# Transition to the end game scene when time runs out
	#var end_game_scene = preload("res://path_to_end_game_scene.tscn")
	#get_tree().change_scene_to(end_game_scene)
	GlobalManager.score = score
	get_tree().change_scene_to_file("res://scenes/end_game.tscn")

func add_points(points):
	score += points
	points_text.text = str(score)
