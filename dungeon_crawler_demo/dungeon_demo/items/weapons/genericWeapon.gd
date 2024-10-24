extends Area2D

class_name GenericWeapon

@export var damage = 1
@export var durability = 1
@export var sprite = ""
@export var stamina_cost = 1

var durability_cost = 1
var curr_durability = 1.0 # Percentage of full durability

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

# Weapon effect is being equipped!
# weapon damage is added to creature base damage when dealing harm
func apply_effect(player: Node2D) -> void:
	player.equip_weapon(self)

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
	
	if curr_durability <= 0.1:
		self.get_parent().get_parent().can_move = true
		queue_free()
	pass

func start_attack(direction) -> void:
	if current_state == state.IDLE:
		attack_direction = direction
		current_state = state.ATTACK
	return

func creature_hit(body: Node2D) -> void:
	# Prevent hitting yourself
	var wielder = self.get_parent().get_parent()
	if wielder != body:
		if body is Creature and body not in hit_enemies:
			hit_enemies[body] = true
			body.take_damage(damage + wielder._damage)
			if not body.immovable:
				body.knockback(self.get_parent().get_parent(),400)
			# Monster's weapons do not break
			if wielder.name == "Player":
				curr_durability -= max(((1.0*durability_cost)/durability),0.1)
				print(curr_durability)
				wielder.update_weapon_durabilit(curr_durability)
