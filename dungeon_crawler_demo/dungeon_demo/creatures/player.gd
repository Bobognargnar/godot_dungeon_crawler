extends Creature

signal player_hit(dam: float)

var can_move = true

func _ready() -> void:
	super()
	hide()

""""
attack_directions
0 1 2
3 + 4
5 6 7
"""
enum attack_direction {UPLEFT,UP,UPRIGHT,LEFT,RIGHT,DOWNLEFT,DOWN,DOWNRIGHT}

var last_attack_dir = facing_direction

# Manage creature movement. Default creature doesn't move!
func _move(delta: float) -> Vector2:
	var delta_v = Vector2.ZERO
	
	# Print pressed inputs so I can see what is arriving
	var msg = ''
	if Input.is_action_pressed("attack"): msg += "attack "
	if Input.is_action_pressed("move_left"): msg += "left "
	if Input.is_action_pressed("move_right"): msg += "right "
	if Input.is_action_pressed("move_up"): msg += "up "
	if Input.is_action_pressed("move_down"): msg += "down "
	
	last_attack_dir = _get_attack_direction()
	#if len(msg)>0: 
		#print(msg)
	#print(last_attack_dir)
	
	if can_move:
		if Input.is_action_pressed("move_right"):
			delta_v.x += 1
		if Input.is_action_pressed("move_left"):
			delta_v.x -= 1
		if Input.is_action_pressed("move_down"):
			delta_v.y += 1
		if Input.is_action_pressed("move_up"):
			delta_v.y -= 1
	
	if Input.is_action_pressed("attack") and _can_attack():
		#print("attack " + dir)
		$Weapon.get_child(0).start_attack(last_attack_dir)
		can_move = false
	
	return delta_v

func _can_attack() -> bool:
	if ($Weapon.get_child_count()>0 
		and $Weapon.get_child(0).current_state==2):
			return true
	return false


# Select one attack direction give the current pressed inputs
func _get_attack_direction() -> int:
	if (Input.is_action_pressed("move_up") and Input.is_action_pressed("move_left")):
		return attack_direction.UPLEFT
	if (Input.is_action_pressed("move_up") and Input.is_action_pressed("move_right")):
		return attack_direction.UPRIGHT
	if (Input.is_action_pressed("move_down") and Input.is_action_pressed("move_left")):
		return attack_direction.DOWNLEFT
	if (Input.is_action_pressed("move_down") and Input.is_action_pressed("move_right")):
		return attack_direction.DOWNRIGHT
	if (Input.is_action_pressed("move_up")):
		return attack_direction.UP
	if (Input.is_action_pressed("move_down")):
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
	player_hit.emit(1.0*dam/hitpoints)
