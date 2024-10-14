extends Area2D

@export var damage = 10
@export var durability = 5
@export var sprite = preload("res://assets/0x72_DungeonTilesetII_v1.7/0x72_DungeonTilesetII_v1.7/frames/weapon_red_gem_sword.png")

enum state {ATTACK,WAIT,IDLE,RETURN}
var lock_state = false
var current_state = state.IDLE
var current_tween: Tween = Tween.new()

var attack_direction = 'right'
var attack_movement = {
	'right': {'rotation':1.8,'position':Vector2(20,20)},
	'left': {'rotation':-1.8,'position':Vector2(-20,20)}
	}
var return_movement = {
	'right': {'rotation':0,'position':Vector2(0,0)},
	'left': {'rotation':0,'position':Vector2(0,0)}
	}

@export var attack_time = 0.1
@export var wait_time = 0.3
@export var return_time = 0.1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if current_state == state.ATTACK and not lock_state:
		lock_state = true
		current_tween = create_tween()
		
		current_tween.tween_property(self, "rotation", attack_movement[attack_direction]['rotation'], attack_time)
		current_tween.parallel().tween_property(self, "position", attack_movement[attack_direction]['position'], attack_time)
		await current_tween.tween_interval(wait_time).finished
		current_state = state.WAIT

		self.get_parent().get_parent().can_move = true
		current_tween = create_tween()
		current_tween.tween_property(self, "rotation", return_movement[attack_direction]['rotation'], return_time)
		current_tween.parallel().tween_property(self, "position", return_movement[attack_direction]['position'], return_time)
		await current_tween.finished
		current_state = state.IDLE
		lock_state = false
		
	pass

func start_attack(direction) -> void:
	if current_state == state.IDLE:
		attack_direction = direction
		print("Set attack")
		current_state = state.ATTACK
	return
