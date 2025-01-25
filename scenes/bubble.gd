extends Area2D

@export var speed: float = 100
@export var horizontal_speed_range: Vector2 = Vector2(-150, 150)  # Random horizontal speed range
@export var direction_change_interval: float = 1.0  # Time in seconds to change direction
@export var size_range: Vector2 = Vector2(0.5, 1.5)  # Range for bubble sizes (scale factor)
@onready var default_burbulas = $Burbulo_img

@onready var game_manager = $"../GameManager"
@onready var death_sound = $AudioStreamPlayer2D


var parent = get_parent()

var bubble_type: String = parent.bubble_type  # Default type is "blue"

var horizontal_speed: float  # Horizontal speed component
var vertical_speed: float = 50  # Vertical speed for the bubble rising
var direction_timer: float = 0.0  # Timer for direction changes

# To store the velocity for bouncing off other bubbles
var velocity: Vector2
var bubble_radius: float  # Store the radius of the bubble for accurate collision

func _on_ready() -> void:
	default_burbulas.play("bubble")
	# Generate a random horizontal speed within the specified range
	horizontal_speed = randf_range(horizontal_speed_range.x, horizontal_speed_range.y)
	# Randomly set the size (scale) of the bubble within the specified range
	var random_size = randf_range(size_range.x, size_range.y)
	scale = Vector2(random_size, random_size)  # Set the same scale for both x and y
	# Calculate the bubble's radius based on the scale
	bubble_radius = scale.x / 2  # Assuming the bubble is circular, radius is half of the scale
	# Initial velocity for the bubble's movement
	velocity = Vector2(horizontal_speed, -vertical_speed)


func _process(delta):
	# Update direction change timer
	direction_timer -= delta
	if direction_timer <= 0:
		# Change horizontal direction randomly
		horizontal_speed = randf_range(horizontal_speed_range.x, horizontal_speed_range.y)
		# Reset the timer to change direction again after a random interval
		direction_timer = randf_range(0.5, direction_change_interval)

	# Apply the horizontal and vertical movement based on velocity
	position += velocity * delta

	# Bounce off the left and right edges of the screen
	if position.x <= 10 or position.x >= 1024:
		velocity.x = -velocity.x  # Reverse horizontal direction

	# Remove the bubble if it goes off-screen at the top
	if position.y < -20:
		queue_free()
	#if is_colliding:
		
		
func _on_area_entered(area: Area2D) -> void:
	# Check if the other object is also a bubble (i.e., another Area2D node)
	if area == self:
		return

		# Calculate the vector from this bubble to the other bubble (collision normal)
	var normal = (position - area.position).normalized()

	# Calculate the relative velocity between the two bubbles
	var relative_velocity = velocity - area.velocity  # `area.velocity` is the other bubble's velocity
	
	# Calculate the velocity component along the normal
	var dot_product = relative_velocity.dot(normal)

	# Only apply reflection if there is a collision (dot product > 0)
	if dot_product > 0:
		# Calculate the reflected velocity using the reflection formula
		# Reflect the velocity of both bubbles along the normal
		velocity = velocity - 2 * dot_product * normal
		area.velocity = area.velocity - 2 * dot_product * normal  # Apply reflection to the other bubble
		# Optionally, add some random variance to the bounce for added dynamism
		velocity += Vector2(randf_range(-50, 50), randf_range(-50, 50))
		area.velocity += Vector2(randf_range(-50, 50), randf_range(-50, 50))
			

func dead():
	default_burbulas.play("pop")
	await default_burbulas.animation_finished
	queue_free()

func handle_bubble_effect():
	
	match bubble_type:
		"blue":
			game_manager.add_points(10)
		"red":
			game_manager.add_points(-10)
		"green":
			game_manager.add_points(10)
		"grey":
			game_manager.add_points(10)
		"purple":
			game_manager.add_points(10)


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		handle_bubble_effect()
		death_sound.play()
		velocity = Vector2(0, 0)
		dead()
		#queue_free()  # Destroy the bubble
		#get_tree().call_group("GameManager", "add_score", 10)  # Notify GameManager
