extends CharacterBody2D

class_name Creature

signal hit # Signals when the creature is being hit

@export var speed = 400
@export var acc = 1000
@export var brake = 2000
@export var can_open_doors = false

var _damage = 0 # This is the real damage!!!
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

var can_move = true

# Damage animation tween storage
var damage_tweens = []

# Modifier timers
var modifier_timers = []

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
	
	if not can_move: delta_v = Vector2.ZERO

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
	
	# Update timer modifiers!
	var updated_modifers = []
	for modifier in modifier_timers:
		modifier["duration"] -= delta
		if modifier["duration"] <= 0:
			apply_modifier(modifier["stat"],modifier["modifier"],0)
		else:
			updated_modifers.append(modifier)
	modifier_timers = updated_modifers
	

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
	var new_weapon = weapon.duplicate()
	new_weapon.position = Vector2(0,0)
	#new_weapon.curr_durability = new_weapon.durability
	new_weapon.get_node("Sprite").scale = Vector2(1,1)
	$Weapon.call_deferred("add_child",new_weapon)

# It's only used by the player to update the hud
func update_weapon_durabilit(durability) -> void:
	pass

func attack_weapon() -> void:
	start_attack_time = Time.get_ticks_msec()
	pass


func take_damage(dam: int) -> void:
	var dam_perc = 1.0*dam/hitpoints
	
	# Show and animate new damage indicator
	$PopUpIndicator.animate(str(-dam),20,1)
	#var new_damage = $DamageIndicator.duplicate()
	#self.add_child(new_damage)
	#new_damage.show()
	#new_damage.get_child(0).text = str(-dam)
	#var dam_tween = create_tween()
	#dam_tween.tween_property(new_damage, "position", Vector2(new_damage.position.x,new_damage.position.y-20), 1)
	#var mod = new_damage.modulate
	#dam_tween.parallel().tween_property(new_damage, "modulate", Color(mod.r,mod.g,mod.b,0.1), 1)
	#dam_tween.connect("finished", on_tween_finished.bind(new_damage))

	
	# Update health bar
	$HealthBar.value -= dam_perc
	if $HealthBar.value <= 0:
		can_move = false
		$DamageArea.get_child(0).set_deferred("disabled",true)
		$CollisionShape2D.set_deferred("disabled",true)
		var smod = self.modulate
		var death_tween = create_tween()
		death_tween.tween_property(self,"modulate",Color(smod.r,smod.g,smod.b,0),1)
		death_tween.connect("finished", on_tween_finished.bind(self))

# Delete animated element after the tween is done
func on_tween_finished(animated_element: Node2D) -> void:
	animated_element.queue_free()
	

func knockback(enemy: Node2D, strength: float) -> void:
	is_knockback = true
	var knockback_direction = (enemy.global_position - global_position).normalized()
	velocity = knockback_direction * strength * -1
	#print(velocity)
	move_and_slide()
	is_knockback = false
	
func apply_modifier(stat:String,modifier:float, duration: float) -> void:
	# Apply a temporary buff or debuff to the creature
	# duration: value 0 has no expiration
	if duration>0: modifier_timers.append({"stat":stat,"modifier":-modifier,"duration":duration})
	
	if stat == "damage":
		# damage modifier is applied to creature damage stat. This is added
		# to the weapon damage, if there is a weapon, so it stacks.
		print("Damage mod: " + str(modifier))
		_damage += modifier
