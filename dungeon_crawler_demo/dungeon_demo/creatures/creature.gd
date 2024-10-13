extends CharacterBody2D

class_name Creature

signal hit # Signals when the creature is being hit

@export var speed = 400
@export var acc = 1000
@export var brake = 2000

@export var hitpoints = 1

var current_hp = 5
var screen_size # Size of the game window.

@onready var weapon = $Weapon # Reference to the Weapon node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# TODO manage dynamic equipment with creature names
	if "_sword" in name:
		var sword_texture = preload("res://.godot/imported/weapon_red_gem_sword.png-ad2e5ed9db3deebf97cd818cb7209a7c.ctex")
		weapon.rotation=-30.5
		weapon.position=Vector2(-5, 5)
		equip_weapon(sword_texture)
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
		
		if velocity.x < 0 and not $AnimatedSprite2D.flip_h:
			_turn_left()
		if velocity.x > 0 and $AnimatedSprite2D.flip_h:
			_turn_right()
		
	move_and_slide()

func _turn_left():
	"""Creature facing left """
	$AnimatedSprite2D.flip_h = true
	$Weapon.rotation = abs($Weapon.rotation)
	$Weapon.position = Vector2(-$Weapon.position.x, $Weapon.position.y)
	
func _turn_right():
	"""Creature facing right """
	$AnimatedSprite2D.flip_h = false
	$Weapon.rotation = -abs($Weapon.rotation)
	$Weapon.position = Vector2(-$Weapon.position.x, $Weapon.position.y)

# Method to equip a weapon
func equip_weapon(texture: Texture) -> void:
	weapon.texture = texture
	weapon.visible = true

func take_damage(dam: int) -> void:
	print("%s toook %s damage" % [name,dam])
