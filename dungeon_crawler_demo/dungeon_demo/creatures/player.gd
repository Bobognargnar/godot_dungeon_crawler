extends Creature

func _ready() -> void:
	super()
	hide()

# Manage creature movement. Default creature doesn't move!
func _move(delta: float) -> Vector2:
	var delta_v = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		delta_v.x += 1
	if Input.is_action_pressed("move_left"):
		delta_v.x -= 1
	if Input.is_action_pressed("move_down"):
		delta_v.y += 1
	if Input.is_action_pressed("move_up"):
		delta_v.y -= 1
	
	return delta_v

func start(pos):
	position = pos
	show()
