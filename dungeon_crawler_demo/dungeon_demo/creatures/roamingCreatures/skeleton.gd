extends RoamingCreature

@export var damage = 5
@onready var navigation_agent: NavigationAgent2D = get_node("NavigationAgent2D")

var target = null
var goto_target = false

func _process(delta: float) -> void:
	super(delta)
	
	if target:
		var player_position = $RayCast2D.to_local(target.global_position)
		$RayCast2D.set_target_position(player_position)
		if $RayCast2D.is_colliding() and $RayCast2D.get_collider().name=='Player':
			#print(name + " has LOS with Player")
			goto_target = true
			set_movement_target(target.position)

func set_movement_target(target: Vector2):
	navigation_agent.set_target_position(target)

func _physics_process(delta):
	# Do not query when the map has never synchronized and is empty.
	if NavigationServer2D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		return
	if navigation_agent.is_navigation_finished():
		print("bad")
		return

	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	var new_velocity: Vector2 = global_position.direction_to(next_path_position) * acc
	navigation_agent.set_velocity(new_velocity)
	move_and_slide()
	#if navigation_agent.avoidance_enabled:
	#else:
		#_on_velocity_computed(new_velocity)

func _on_velocity_computed(safe_velocity: Vector2):
	print("velocity computed")
	velocity = safe_velocity
	print(safe_velocity)
	move_and_slide()

func _on_damage_area_body_entered(body: Node2D) -> void:
	if body.name == 'Player':
		body.take_damage(damage)
		body.knockback(self,400)
	#$CollisionShape2D.set_deferred("disabled", true)
