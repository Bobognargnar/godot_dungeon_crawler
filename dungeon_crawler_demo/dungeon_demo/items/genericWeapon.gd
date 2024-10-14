extends Area2D

@export var damage = 10
@export var durability = 10
@export var sprite = preload("res://assets/0x72_DungeonTilesetII_v1.7/0x72_DungeonTilesetII_v1.7/frames/weapon_red_gem_sword.png")
@export var stamina_cost = 2

enum state {ATTACK,WAIT,IDLE,RETURN}
var lock_state = false
var current_state = state.IDLE
var current_tween: Tween = Tween.new()

enum dir_mappings {UPLEFT,UP,UPRIGHT,LEFT,RIGHT,DOWNLEFT,DOWN,DOWNRIGHT,UP_FROMLEFT,DOWN_FROMLEFT}
var attack_direction = 'right'
var attack_movement = {
	dir_mappings.RIGHT: {'rotation':1.8,'position':Vector2(20,20)},
	dir_mappings.LEFT: {'rotation':-1.8,'position':Vector2(-20,20)},
	
	# These work if facing right
	dir_mappings.UP: {'rotation':0.8,'position':Vector2(20,-10)},
	dir_mappings.DOWN: {'rotation':3.6,'position':Vector2(0,30)},
	# These work if facing left
	dir_mappings.UP_FROMLEFT: {'rotation':-0.8,'position':Vector2(-20,-10)},
	dir_mappings.DOWN_FROMLEFT: {'rotation':-3.6,'position':Vector2(0,30)},
	
	
	#dir_mappings.UPLEFT: {'rotation':1.4,'position':Vector2(20,-10)},
	#dir_mappings.UPRIGHT: {'rotation':-1.4,'position':Vector2(20,-10)},
	#dir_mappings.DOWNLEFT: {'rotation':1.5,'position':Vector2(0,20)},
	#dir_mappings.DOWNRIGHT: {'rotation':1.5,'position':Vector2(0,20)},
	}
var return_movement = {
	dir_mappings.RIGHT: {'rotation':0,'position':Vector2(0,0)}
	}

@export var attack_time = 0.1
@export var wait_time = 0.3
@export var return_time = 0.1

var hit_enemies = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Hitbox.disabled = true
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	if current_state == state.ATTACK and not lock_state:
		lock_state = true
		$Hitbox.disabled = false
		current_tween = create_tween()
		
		current_tween.tween_property(self, "rotation", attack_movement[attack_direction]['rotation'], attack_time)
		current_tween.parallel().tween_property(self, "position", attack_movement[attack_direction]['position'], attack_time)
		await current_tween.tween_interval(wait_time).finished
		current_state = state.WAIT

		self.get_parent().get_parent().can_move = true
		current_tween = create_tween()
		current_tween.tween_property(self, "rotation", return_movement[dir_mappings.RIGHT]['rotation'], return_time)
		current_tween.parallel().tween_property(self, "position", return_movement[dir_mappings.RIGHT]['position'], return_time)
		await current_tween.finished
		current_state = state.IDLE
		lock_state = false
		hit_enemies = {}
		$Hitbox.disabled = true
	
	if durability <= 0:
		self.get_parent().get_parent().can_move = true
		queue_free()
	pass

func start_attack(direction) -> void:
	print("Attempt attack")
	if current_state == state.IDLE:
		attack_direction = direction
		print("Set attack!!" + str(direction))
		current_state = state.ATTACK
	return

func creature_hit(body: Node2D) -> void:
	# Prevent hitting yourself
	if self.get_parent().get_parent() != body:
		if body is Creature and body not in hit_enemies:
			print("Hit " + body.name)
			hit_enemies[body] = true
			body.take_damage(damage)
			if not body.immovable:
				body.knockback(self.get_parent().get_parent(),400)
			durability -= 1
