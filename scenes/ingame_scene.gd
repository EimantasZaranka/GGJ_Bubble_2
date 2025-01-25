extends Node2D

@onready var fade_overlay = %FadeOverlay
@onready var pause_overlay = %PauseOverlay
@onready var bubble_spawner_timer: Timer = $BubbleTimer

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

@export var bubble_scene: PackedScene
@export var spawn_area_width: float = 1024  # Width of the area where bubbles can spawn

func _on_bubble_timer_timeout() -> void:
	# Instance a new bubble
	var bubble = bubble_scene.instantiate()
	
	# Set a random horizontal position for the bubble
	var x_pos = randf_range(0, spawn_area_width)
	bubble.position = Vector2(x_pos, get_viewport().size.y)
	
	# Add the bubble to the scene
	add_child(bubble)
