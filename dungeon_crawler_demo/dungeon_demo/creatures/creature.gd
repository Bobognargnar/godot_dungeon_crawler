extends CharacterBody2D

class_name Creature

signal hit # Signals when the player is being hit

@export var speed = 400 # How fast the player will move (pixels/sec).
@export var acc = 1000 # How fast the player will move (pixels/sec).
@export var brake = 2000
var screen_size # Size of the game window.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Manage creature movement. Default creature doesn't move!
func _move(delta: float) -> Vector2:
	return Vector2.ZERO

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var delta_v = _move(delta)

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
		$Weapon.flip_v = velocity.x < 0
		if $Weapon.flip_v:
			$Weapon.position = Vector2(-abs($Weapon.position.x), $Weapon.position.y)
		else:
			$Weapon.position = Vector2(abs($Weapon.position.x), $Weapon.position.y)
	move_and_slide()
