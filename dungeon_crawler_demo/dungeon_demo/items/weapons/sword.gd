extends GenericWeapon

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	damage = 10
	durability = 10
	#sprite = preload("res://assets/0x72_DungeonTilesetII_v1.7/0x72_DungeonTilesetII_v1.7/frames/weapon_red_gem_sword.png")
	stamina_cost = 6.0

func start_attack(direction) -> void:
	if current_state == state.IDLE:
		print("Attack")
		$AnimationPlayer.play("attack_left")
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
			# Update weapon durability
			# Monster's weapons do not break
			if wielder.name == "Player":
				curr_durability -= max(((1.0*durability_cost)/durability),0.1)
				wielder.update_weapon_durabilit(curr_durability)
				
				# Hard stop after hitting an enemy?
				wielder.force_hard_stop()
			
				

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	current_state = state.IDLE
	#self.get_parent().get_parent().can_move = true
	
	lock_state = false
	hit_enemies = {}
