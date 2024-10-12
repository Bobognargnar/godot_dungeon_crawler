extends CharacterBody2D

signal hit # Signals when the player is being hit

@export var speed = 400 # How fast the player will move (pixels/sec).
@export var acc = 1000 # How fast the player will move (pixels/sec).
@export var brake = 2000
var screen_size # Size of the game window.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#velocity = Vector2.ZERO # The player's movement vector.
	var delta_v = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		delta_v.x += 1
	if Input.is_action_pressed("move_left"):
		delta_v.x -= 1
	if Input.is_action_pressed("move_down"):
		delta_v.y += 1
	if Input.is_action_pressed("move_up"):
		delta_v.y -= 1

	if delta_v.length() > 0:
		delta_v = delta_v.normalized() * acc * delta
		velocity += delta_v
		# Clamp velocity to max speed
		if velocity.length() > speed:
			velocity = velocity.normalized() * speed
		
	else:
		# Clamp velocity to braking
		if (velocity.length() < brake * delta):
			velocity = Vector2.ZERO
		else:
			velocity -= velocity.normalized() * brake * delta
		
	if velocity.length() > 0:
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
		
		
	if velocity.length() != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		# See the note below about the following boolean assignment.
		$AnimatedSprite2D.flip_h = velocity.x < 0
	
	move_and_slide()
	#position += velocity * delta
	#position = position.clamp(Vector2.ZERO, screen_size)

func start(pos):
	position = pos
	show()
	#$CollisionShape2D.disabled = false
