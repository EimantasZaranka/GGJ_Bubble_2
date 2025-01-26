extends Node2D
#class_name InGameScene

@onready var fade_overlay = %FadeOverlay
@onready var pause_overlay = %PauseOverlay
@onready var bubble_spawner_timer: Timer = $BubbleTimer

@export var bubble_scene: PackedScene
@export var red_bubble_scene: PackedScene
@export var green_bubble_scene: PackedScene
@export var purple_bubble_scene: PackedScene
@export var grey_bubble_scene: PackedScene

@export var spawn_interval: float = 0.025  # Time between spawns
@export var bubble_chances: Dictionary = {
	"blue": 0.6,  # 70% chance for blue bubbles
	"red": 0.1,     # 20% chance for red bubbles
	"green": 0.2,   # 10% chance for golden bubbles
	"purple":0.05,
	"grey":0.05,
}

@export var spawn_area_width: float = 1024  # Width of the area where bubbles can spawn


func _ready() -> void:
	fade_overlay.visible = true
	
	if SaveGame.has_save():
		SaveGame.load_game(get_tree())
	
	pause_overlay.game_exited.connect(_save_game)


func _input(event) -> void:
	if event.is_action_pressed("pause") and not pause_overlay.visible:
		get_viewport().set_input_as_handled()
		get_tree().paused = true
		pause_overlay.grab_button_focus()
		pause_overlay.visible = true
		
func _save_game() -> void:
	SaveGame.save_game(get_tree())


func _on_bubble_timer_timeout() -> void:
	# Instance a new bubble
	#var bubble = bubble_scene.instantiate()
	
	var bubble_type = random_bubble_type()
	var bubble_instance = null

	if bubble_type == "normal":
		bubble_instance = preload("res://scenes/bubble.tscn").instantiate()
		bubble_instance.time_addition = 1
		bubble_instance.score_addition = 1
	elif bubble_type == "red":
		bubble_instance = preload("res://scenes/red_bubble.tscn").instantiate()
		bubble_instance.time_addition = -10
		bubble_instance.score_addition = -10
	elif bubble_type == "green":
		bubble_instance = preload("res://scenes/bubble_green.tscn").instantiate()
		bubble_instance.time_addition = 5
		bubble_instance.score_addition = 10
	elif bubble_type == "purple":
		bubble_instance = preload("res://scenes/purple_bubble.tscn").instantiate()
		bubble_instance.time_addition = 0
		bubble_instance.score_addition = 25
	elif bubble_type == "grey":
		bubble_instance = preload("res://scenes/grey_bubble.tscn").instantiate()
		bubble_instance.time_addition = -1
		bubble_instance.score_addition = 4
	

	if bubble_instance:
		# Set random position and add to scene
		bubble_instance.position = Vector2(randf_range(300, get_viewport().size.x-400), get_viewport().size.y - 250)
		#bubble_instance.set_meta("type_bubble", bubble_type
		#print(bubble_instance.get_meta("type_bubble"))
		bubble_instance.bubble_type = bubble_type
		add_child(bubble_instance)
	
	# Set a random horizontal position for the bubble
	#var x_pos = randf_range(0, spawn_area_width)
	#bubble.position = Vector2(x_pos, get_viewport().size.y)
	
	# Add the bubble to the scene
	#add_child(bubble)
	
func random_bubble_type() -> String:
	var rand = randf()
	var cumulative_chance = 0.0

	for type in bubble_chances.keys():
		cumulative_chance += bubble_chances[type]
		if rand < cumulative_chance:
			return type

	return "blue"  # Default type if something goes wrong
