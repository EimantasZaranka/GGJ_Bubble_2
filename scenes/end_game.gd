extends Control

@onready var score_label = $Label2 # Reference the second Label node for the score
@onready var main_menu_button = $Button  # Reference the Button node


func _ready():
	# Set the score text (this will be passed from the previous scene)
	score_label.text = "Your Score: " + str(GlobalManager.score)

	# Connect the button's pressed signal
	main_menu_button.connect("pressed", Callable(self, "_on_main_menu_button_pressed"))

func _on_main_menu_button_pressed():
	# Change the scene to the main menu
	get_tree().change_scene_to_file("res://scenes/main_menu_scene.tscn")
