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
	

func _process(delta: float) -> void:
	# Rotate player following mouse position
	look_at(get_global_mouse_position()) 
	
	super(delta) # This handle moves
	
	stamina_timeout_s -= delta
	if stamina_timeout_s <= 0: 
		stamina_timeout_s=0
		if stamina < max_stamina:
			_gain_stamina(stamina_regen)
			stamina_change.emit((1.0*stamina_regen)/max_stamina)
	#print(stamina_timeout_s)
	
	if Input.is_action_pressed("attack") and _can_attack():
		
		# Handle stamina usage
		if stamina_timeout_s <=0:
			if $Weapon.get_child(0).stamina_cost <= stamina:
				$Weapon.get_child(0).start_attack(last_attack_dir)
				can_move = false
			else:
				print("Stamina too low")
				
			stamina_timeout_s = $Weapon.get_child(0).wait_time
			_consume_stamina($Weapon.get_child(0).stamina_cost)
			# On change of stamina value, signal everyone
			stamina_change.emit((-1.0*$Weapon.get_child(0).stamina_cost)/max_stamina)
			
	
	# Handle stamina regeneration
	# If stamina recovery timer is expired, recover stamina
	# change_stamina.emit()

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
	#take_damage(-hitpoints)
	set_collision_mask_value(1,true)
	set_collision_layer_value(1,true)
	immovable = false
	is_disabled = false
	can_move = true

# Manage creature movement. Default creature doesn't move!
func _move(delta: float) -> Vector2:
	var delta_v = Vector2.ZERO
	
	last_attack_dir = _get_attack_direction()
	
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
