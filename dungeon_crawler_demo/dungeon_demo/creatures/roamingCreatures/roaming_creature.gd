extends Creature

class_name RoamingCreature

@export var min_move_time = 0.5 # Minimum time to move in one direction
@export var max_move_time = 1.5 # Maximum time to move in one direction
@export var min_stop_time = 0.5 # Minimum time to stop
@export var max_stop_time = 1.5 # Maximum time to stop

var move_timer = 0.0
var stop_timer = 0.0
var moving = true
var direction = Vector2.ZERO

func _ready() -> void:
	super()
	_set_new_direction()

var rng = RandomNumberGenerator.new()


func _move(delta: float) -> Vector2:
	"""Roaming creature moves in random direction
	"""
	if moving:
		move_timer -= delta
		if move_timer <= 0:
			moving = false
			stop_timer = randf_range(min_stop_time, max_stop_time)
	else:
		direction = Vector2.ZERO
		stop_timer -= delta
		if stop_timer <= 0:
			_set_new_direction()
			moving = true
			move_timer = randf_range(min_move_time, max_move_time)
	return direction

func _set_new_direction() -> void:
	direction = Vector2(randi_range(-1,1), randi_range(-1,1)).normalized()
