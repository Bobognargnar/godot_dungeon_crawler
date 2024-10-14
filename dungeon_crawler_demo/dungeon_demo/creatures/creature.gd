extends CharacterBody2D

class_name Creature

signal hit # Signals when the creature is being hit

@export var speed = 400
@export var acc = 1000
@export var brake = 2000

@export var hitpoints = 20
@export var immovable = false

var is_attacking = false
""""
attack_directions
0 1 2
3 + 4
5 6 7
"""
enum attack_direction {UPLEFT,UP,UPRIGHT,LEFT,RIGHT,DOWNLEFT,DOWN,DOWNRIGHT,UP_FROMLEFT,DOWN_FROMLEFT}
var facing_direction = attack_direction.RIGHT

var screen_size # Size of the game window.

var start_attack_time = 0
var is_knockback = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# TODO manage dynamic equipment with creature names
	pass

# Manage creature movement. Default creature doesn't move!
func _move(delta: float) -> Vector2:
	return Vector2.ZERO

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_knockback: return
	
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
	
	"""
	if tmp_tween and tmp_tween.is_running() and action=="ATTACK":
		tmp_tween.tween_property($Weapon, "position", Vector2(0,0), 1.0)
		action = "RETURN"
	if tmp_tween and tmp_tween.is_running() and action=="RETURN":
		is_attacking = false
		action = "IDLE"	
	"""
		
	

func _turn_left():
	"""Creature facing left """
	facing_direction = attack_direction.LEFT
	$AnimatedSprite2D.flip_h = true
	$Weapon.rotation = abs($Weapon.rotation)
	$Weapon.position = Vector2(-$Weapon.position.x, $Weapon.position.y)
	
func _turn_right():
	"""Creature facing right """
	facing_direction = attack_direction.RIGHT
	$AnimatedSprite2D.flip_h = false
	$Weapon.rotation = -abs($Weapon.rotation)
	$Weapon.position = Vector2(-$Weapon.position.x, $Weapon.position.y)

# Method to equip a weapon
func equip_weapon(weapon) -> void:
	print("Equip Weapons!")
	var new_weapon = weapon.duplicate()
	new_weapon.position = Vector2(0,0)
	new_weapon.get_node("Sprite").scale = Vector2(1,1)
	$Weapon.call_deferred("add_child",new_weapon)

func attack_weapon() -> void:
	
	start_attack_time = Time.get_ticks_msec()
	pass

func take_damage(dam: int) -> void:
	var dam_perc = 1.0*dam/hitpoints
	#print($HealthBar)
	$HealthBar.value -= dam_perc
	if $HealthBar.value <= 0:
		queue_free()

func knockback(enemy: Node2D, strength: float) -> void:
	is_knockback = true
	var knockback_direction = (enemy.global_position - global_position).normalized()
	velocity = knockback_direction * strength * -1
	print(velocity)
	move_and_slide()
	is_knockback = false
