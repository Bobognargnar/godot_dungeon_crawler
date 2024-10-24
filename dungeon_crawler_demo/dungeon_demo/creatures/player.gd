extends Creature

# Percentage of HP lost
signal player_hit(dam: float)

signal move_to_inventory_hud(item: Node2D)
signal move_to_weapons_hud(item: Node2D)
signal move_to_collection_hud(item: Node2D)
signal remove_from_inventory_hud(item: Node2D)
signal update_weapon_durabilit_hud(dur: float)

# Percentage of STAMINA changed
signal stamina_change(stam: float)
var max_stamina = 10
var stamina = 10
var stamina_regen = 0.1
@export var hitpoints = 50

#var can_move = false
var is_disabled = true

# All unique non consumable items are here
var collection = []

func _ready() -> void:
	super()
	_hitpoints = hitpoints
	hide()

var last_attack_dir = facing_direction

var stamina_timeout_s = 0



func _consume_stamina(cost:int):
	#print("Consuming stamina " + str(cost) + " of " + str(stamina))
	if stamina >= cost:
		stamina -= cost
	else:
		stamina = 0

func _gain_stamina(reg:float):
	#print("Gain stamina " + str(reg) + " plus " + str(stamina))
	stamina += reg
	if stamina >= max_stamina:
		stamina = max_stamina
	

var move_delay = 0.0

func _process(delta: float) -> void:
	
	lounge_delay = max(0,lounge_delay-delta)
	move_delay = max(0,move_delay-delta)
	
	# Player movement manager
	if is_knockback: return
	
	
	
	var delta_v = _move(delta)
	var new_velocity = compute_velocity(delta_v,delta)
	velocity = new_velocity
	
	
	
	if move_delay > 0:
		can_move = false
	else:
		can_move = true
	
	if lounge_delay == 0 and lounge!=Vector2.ZERO:
		velocity = Vector2.ZERO
		velocity = lounge*5*delta
		lounge = Vector2.ZERO
		move_delay = 0.5
	
	if hard_stop:
		velocity = Vector2.ZERO
		hard_stop = false
	
	move_and_slide()
	# Player movement animation manager
	_animate_player_movement(delta_v)
	
	#move_and_slide()
	
	# Rotate player following mouse position
	#look_at(get_global_mouse_position()) 
	
	#super(delta) # This handle moves
	
	# Player stamina manager
	stamina_timeout_s -= delta
	stamina_timeout_s = max(0,stamina_timeout_s)
	if stamina_timeout_s == 0:
		if stamina < max_stamina:
			_gain_stamina(stamina_regen)
			stamina_change.emit((1.0*stamina_regen)/max_stamina)
	
	# Player attack manager
	if Input.is_action_pressed("attack") and _can_attack():
		
		# Handle stamina usage
		if stamina_timeout_s <=0:
			if $Weapon.get_child(0).stamina_cost <= stamina:
				is_attacking = true
				# Player attack animation manager
				_animate_player_attack()
				#velocity += lounge
				
				can_move = false
				
				stamina_timeout_s = $Weapon.get_child(0).wait_time
				_consume_stamina($Weapon.get_child(0).stamina_cost)
				# On change of stamina value, signal everyone
				stamina_change.emit((-1.0*$Weapon.get_child(0).stamina_cost)/max_stamina)
			else:
				print("Stamina too low")
			
	
	
	
			
	
	# Handle stamina regeneration
	# If stamina recovery timer is expired, recover stamina
	# change_stamina.emit()


var idle_animation = "idle_right"
var walk_animation = "walk_right"
var facing_direction = "right"
var attack_animation = "attack_right"
var lounge = Vector2.ZERO
var lounge_delay = 0.0
var hard_stop = false

# Manage idle and movement animation
func _animate_player_movement(delta_v: Vector2) -> void:

	if delta_v == Vector2.ZERO:
		if is_attacking: return
		$AnimationPlayer.play("idle_"+facing_direction)
		# TODO this would be better with AnimationTree
		if $Weapon.get_child_count()>0:
			$Weapon.get_child(0).get_node("AnimationPlayer").play("idle_"+facing_direction)
			$Weapon.get_child(0).get_node("AnimationPlayer").seek($AnimationPlayer.get_current_animation_position())
		return
		
	elif (delta_v.angle()>=0 and delta_v.angle()<(PI/2)*0.9):
		$SpriteIdle.flip_h = false
		facing_direction = "right"
	elif (delta_v.angle()>(PI/2)*1.1 and delta_v.angle()<=(PI)*1.01):
		$SpriteIdle.flip_h = true
		facing_direction = "right"
	elif (delta_v.angle()>=(PI/2)*0.9 and delta_v.angle()<=(PI/2)*1.1):
		facing_direction = "down"
	elif (delta_v.angle()<=-(PI/2)*0.9 and delta_v.angle()>=-(PI/2)*1.1):
		facing_direction = "up"
	elif (delta_v.angle()<=-(PI/2)*1.1):
		$SpriteIdle.flip_h = false
		facing_direction = "left_up"
	elif (delta_v.angle()>=-(PI/2)*0.9 and delta_v.angle()<=0):
		$SpriteIdle.flip_h = true
		facing_direction = "left_up"
	
	if is_attacking: return
	$AnimationPlayer.play("walk_"+facing_direction)
	if $Weapon.get_child_count()>0:
		$Weapon.get_child(0).get_node("AnimationPlayer").play("walk_"+facing_direction)
		$Weapon.get_child(0).get_node("AnimationPlayer").seek($AnimationPlayer.get_current_animation_position())
	pass

# Manage attack animation
func _animate_player_attack() -> void:
	if not is_attacking: return
	$AnimationPlayer.play("attack_"+facing_direction)
	$Weapon.get_child(0).get_node("Sprite3").flip_h = $SpriteIdle.flip_h
	if $SpriteIdle.flip_h and facing_direction=="right":
		$Weapon.get_child(0).get_node("AnimationPlayer").play("attack_left")
	elif $SpriteIdle.flip_h and facing_direction=="left_up":
		$Weapon.get_child(0).get_node("AnimationPlayer").play("attack_right_up")
	else:
		$Weapon.get_child(0).get_node("AnimationPlayer").play("attack_"+facing_direction)
	$Weapon.get_child(0).get_node("AnimationPlayer").seek($AnimationPlayer.get_current_animation_position())
	
	# Lounge attack!
	var delta = Vector2.ZERO
	if facing_direction == "right" and not $SpriteIdle.flip_h:
		delta.x += 500
	if facing_direction == "right" and $SpriteIdle.flip_h:
		delta.x -= 500
	if facing_direction == "left_up" and not $SpriteIdle.flip_h:
		delta.x += 250
		delta.y -= 250
	if facing_direction == "left_up" and $SpriteIdle.flip_h:
		delta.x -= 250
		delta.y -= 250
	if facing_direction == "up":
		delta.y -= 500
	if facing_direction == "down":
		delta.y += 500
	lounge = delta
	lounge_delay = 0.2
	

func force_hard_stop() -> void:
	hard_stop = true
	

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if "attack_" in anim_name and is_attacking:
		can_move = true
		is_attacking = false
		velocity = -0.5* velocity

	

func disable_player() -> void:
	hide()
	set_collision_mask_value(1,false)
	set_collision_layer_value(1,false)
	$CollisionShape2D.disabled = true
	immovable = true
	is_disabled = true
	can_move = false

func enable_player() -> void:
	show()
	$AnimationPlayer.play("idle_right")
	#take_damage(-hitpoints)
	set_collision_mask_value(1,true)
	set_collision_layer_value(1,true)
	immovable = false
	is_disabled = false
	can_move = true

# Manage player movement controls and return a direction vector
func _move(delta: float) -> Vector2:
	var delta_v = Vector2.ZERO
	
	
	if can_move:
		if Input.is_action_pressed("move_right"):
			delta_v.x += 1
		if Input.is_action_pressed("move_left"):
			delta_v.x -= 1
		if Input.is_action_pressed("move_down"):
			delta_v.y += 1
		if Input.is_action_pressed("move_up"):
			delta_v.y -= 1
	
	return delta_v

func _can_attack() -> bool:
	if ($Weapon.get_child_count()>0 
		and $Weapon.get_child(0).current_state==2):
			return true
	return false


# Select one attack direction give the current pressed inputs
func _get_attack_direction() -> int:
	#if (Input.is_action_pressed("move_up") and Input.is_action_pressed("move_left")):
		#return attack_direction.UPLEFT
	#if (Input.is_action_pressed("move_up") and Input.is_action_pressed("move_right")):
		#return attack_direction.UPRIGHT
	#if (Input.is_action_pressed("move_down") and Input.is_action_pressed("move_left")):
		#return attack_direction.DOWNLEFT
	#if (Input.is_action_pressed("move_down") and Input.is_action_pressed("move_right")):
		#return attack_direction.DOWNRIGHT
	if (Input.is_action_pressed("move_up")):
		if facing_direction == attack_direction.LEFT:
			return attack_direction.UP_FROMLEFT
		return attack_direction.UP
	if (Input.is_action_pressed("move_down")):
		if facing_direction == attack_direction.LEFT:
			return attack_direction.DOWN_FROMLEFT
		return attack_direction.DOWN
	if (Input.is_action_pressed("move_left")):
		return attack_direction.LEFT
	if (Input.is_action_pressed("move_right")):
		return attack_direction.RIGHT
	return last_attack_dir

func start(pos):
	position = pos
	show()
	print("Idling")
	$AnimationPlayer.play("idle_right")

func take_damage(dam: int) -> void:
		# Show and animate new damage indicator
	$PopUpIndicator.animate(str(-dam),20,1)
	player_hit.emit(1.0*dam/_hitpoints)

func equip_weapon(weapon: Node2D) -> void:
	super(weapon) # Creature equips weapon too
	weapon.get_node("Sprite3").hide()
	move_to_weapons_hud.emit(weapon)

# To update the hud
func update_weapon_durabilit(dur_perc: float) -> void:
	update_weapon_durabilit_hud.emit(dur_perc)
	pass

func move_to_inventory(item: Node2D) -> void:
	print("Player: move to inventory " + item.name)
	move_to_inventory_hud.emit(item)

func move_to_collection(item: Node2D) -> void:
	print("Player: move to collection " + item.name)
	collection.append(item)
	move_to_collection_hud.emit(item)

func remove_from_inventory(item: Node2D) -> void:
	print("Player: remove from inventory" + item.name)
