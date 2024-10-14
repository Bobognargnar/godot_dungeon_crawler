extends Creature

signal player_hit(dam: float)

var can_move = true

func _ready() -> void:
	super()
	hide()



# Manage creature movement. Default creature doesn't move!
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
	
	if Input.is_action_pressed("attack") and $Weapon.get_child_count()>0 and $Weapon.get_child(0).current_state==2:
		$Weapon.get_child(0).start_attack(facing_direction)
		can_move = false
	
	return delta_v

func start(pos):
	position = pos
	show()

func take_damage(dam: int) -> void:
	player_hit.emit(1.0*dam/hitpoints)
