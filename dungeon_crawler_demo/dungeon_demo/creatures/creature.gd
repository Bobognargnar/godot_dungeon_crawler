extends CharacterBody2D

class_name Creature

signal hit # Signals when the creature is being hit

@export var speed = 400
@export var acc = 1000
@export var brake = 2000
@export var can_open_doors = false

var _damage = 0 # This is the real damage!!!
@export var _hitpoints = 1
@export var immovable = false

var is_attacking = false
#""""
#attack_directions
#0 1 2
#3 + 4
#5 6 7
#"""
#enum attack_direction {UPLEFT,UP,UPRIGHT,LEFT,RIGHT,DOWNLEFT,DOWN,DOWNRIGHT,UP_FROMLEFT,DOWN_FROMLEFT}
#var facing_direction = attack_direction.RIGHT

var start_attack_time = 0
var is_knockback = false

var can_move = true

# Damage animation tween storage
var damage_tweens = []

# Modifier timers
var modifier_timers = []

var is_disabled = true

var last_attack_dir = facing_direction
var move_delay = 0.0
var move_delay_active = false

var lunge_duration = 0.0

var idle_animation = "idle_right"
var walk_animation = "walk_right"
var facing_direction = "right"
var attack_animation = "attack_right"
var lounge = Vector2.ZERO
var lounge_delay = 0.0
var hard_stop = false
var freeze_animation = false

# Targetting component
var target = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# TODO manage dynamic equipment with creature names
	pass

# Manage creature movement. Default creature doesn't move!
func _move(delta: float) -> Vector2:
	return Vector2.ZERO

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
		
	lounge_delay = max(0,lounge_delay-delta) # Delay start of lunge
	move_delay = max(0,move_delay-delta) # Inhibit movement after lunge
	
	# Player movement manager
	if is_knockback: return
	
	var delta_v = _move(delta)
	var new_velocity = compute_velocity(delta_v,delta)
	velocity = new_velocity
	
	# Movement blocked untile the delay is expired
	if can_move and move_delay > 0:
		can_move = false
		move_delay_active = true

	if not can_move and move_delay_active and move_delay == 0:
		can_move = true
		move_delay_active = false
		
	if lounge_delay == 0 and lunge_duration>0 and lounge!=Vector2.ZERO:
		velocity += lounge
		lunge_duration = max(0,lunge_duration-delta) # Duration of boost
		move_delay = 0.2
		
	if lunge_duration == 0 and lounge!=Vector2.ZERO:
		lounge = Vector2.ZERO
		hard_stop = true
	
	if hard_stop:
		velocity = Vector2.ZERO
		hard_stop = false
	
	move_and_slide()
	# Movement animation manager
	_animate_movement(delta_v)
	
	# Modifiers manager
	var updated_modifers = []
	for modifier in modifier_timers:
		modifier["duration"] -= delta
		if modifier["duration"] <= 0:
			apply_modifier(modifier["stat"],modifier["modifier"],0)
		else:
			updated_modifers.append(modifier)
	modifier_timers = updated_modifers
	
	# Component behaviors
	if get_node("BehaviorAttackInRange"):
		get_node("BehaviorAttackInRange").execute()

	

func compute_velocity(delta_v: Vector2,delta:float) -> Vector2:
	
	# Movement is disabled, preserve intertia
	if not can_move: delta_v = Vector2.ZERO
	
	# Move without momentum
	#if delta_v.length() > 0:
		#delta_v = delta_v.normalized() * speed
		#velocity = delta_v
	#else:
		#velocity = Vector2.ZERO
	#return velocity
	
	# Move with momentum
	if delta_v.length() > 0:
		# Accelerate in the movement direction
		delta_v = delta_v.normalized() * acc * delta
		velocity += delta_v
		# Clamp velocity to max speed
		if velocity.length() > speed:
			velocity = velocity.normalized() * speed
		
	else:
		# Preserve momentum but consider braking
		# Clamp velocity to braking
		if (velocity.length() < brake * delta):
			velocity = Vector2.ZERO
		else:
			velocity -= velocity.normalized() * brake * delta
	return velocity

# Method to equip a weapon
func equip_weapon(weapon) -> void:
	var new_weapon = weapon.duplicate()
	new_weapon.position = Vector2(0,0)
	##new_weapon.curr_durability = new_weapon.durability
	new_weapon.get_node("Sprite").hide()
	$Weapon.call_deferred("add_child",new_weapon)
	pass

# It's only used by the player to update the hud
func update_weapon_durabilit(durability) -> void:
	pass

func attack_weapon() -> void:
	pass


func take_damage(dam: int) -> void:
	var dam_perc = 1.0*dam/_hitpoints
	
	# Show and animate new damage indicator
	$PopUpIndicator.animate(str(-dam),20,1)
	
	# Update health bar
	$HealthBar.value -= dam_perc
	var smod = self.modulate
	# Hit animation
	var hit_tween = create_tween()
	hit_tween.tween_property($Sprite, "modulate:v", 1, 0.25).from(15)
	
	if $HealthBar.value <= 0:
		# Death animation
		can_move = false
		$DamageArea.get_child(0).set_deferred("disabled",true)
		$CollisionShape2D.set_deferred("disabled",true)
		hit_tween.tween_property(self,"modulate",Color(smod.r,smod.g,smod.b,0),1)
		hit_tween.connect("finished", on_tween_finished.bind(self))
		# Death freeze
		# TODO this is fucked up by the animation movement
		freeze_animation = true
	
# Delete animated element after the tween is done
func on_tween_finished(animated_element: Node2D) -> void:
	animated_element.queue_free()
	

# Entity knockback
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

# Manage current running animation
func _animation_manager(animation: String) -> void:
	if freeze_animation:
		$AnimationPlayer.stop()
		return
		
	$AnimationPlayer.play(animation)
	# TODO this would be better with AnimationTree
	if $Weapon.get_child_count()>0:
		$Weapon.get_child(0).get_node("AnimationPlayer").play(animation)
		$Weapon.get_child(0).get_node("AnimationPlayer").seek($AnimationPlayer.get_current_animation_position())
	return

# Manage idle and movement animation
func _animate_movement(delta_v: Vector2) -> void:

	if delta_v == Vector2.ZERO:
		if is_attacking: return
		var tmp_facing = facing_direction
		#if tmp_facing == 'left': tmp_facing = 'right'
		_animation_manager("idle_"+tmp_facing)
		return
		
	elif (delta_v.angle()>=0 and delta_v.angle()<(PI/2)*0.9):
		$SpriteIdle.flip_h = false
		$Head.flip_h = false
		facing_direction = "right"
	elif (delta_v.angle()>(PI/2)*1.1 and delta_v.angle()<=(PI)*1.01):
		$SpriteIdle.flip_h = true
		$Head.flip_h = true
		facing_direction = "left"
	elif (delta_v.angle()>=(PI/2)*0.9 and delta_v.angle()<=(PI/2)*1.1):
		facing_direction = "down"
	elif (delta_v.angle()<=-(PI/2)*0.9 and delta_v.angle()>=-(PI/2)*1.1):
		facing_direction = "up"
	elif (delta_v.angle()<=-(PI/2)*1.1):
		$SpriteIdle.flip_h = false
		$Head.flip_h = false
		facing_direction = "left_up"
	elif (delta_v.angle()>=-(PI/2)*0.9 and delta_v.angle()<=0):
		#$SpriteIdle.flip_h = true
		#$Head.flip_h = true
		facing_direction = "right_up"
	
	if is_attacking: return
	
	var tmp_facing = facing_direction
	#if tmp_facing == 'left': tmp_facing = 'right'

	_animation_manager("walk_"+tmp_facing)
