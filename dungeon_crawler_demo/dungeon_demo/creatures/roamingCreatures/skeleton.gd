extends RoamingCreature

#@onready var navigation_agent: NavigationAgent2D = get_node("NavigationAgent2D")

var target = null
@export var damage = 5

var attention_span = 2
var goto_target = 0
var last_position = Vector2.ZERO

func _ready() -> void:
	super()
	_damage = damage # Override default creature damage with concrete creature damage.
	$HealthBar.visible = false

func _move(delta: float) -> Vector2:
	var direction = super(delta)
	
	if target and "global_position" in target:
		var player_position = $RayCast2D.to_local(target.global_position)
		$RayCast2D.set_target_position(player_position)
		if $RayCast2D.is_colliding() and $RayCast2D.get_collider() and $RayCast2D.get_collider().name=='Player':
			goto_target = attention_span
			last_position = $RayCast2D.target_position
			#print(last_position)
		else:
			goto_target -= delta
			if goto_target < 0: goto_target = 0
	if goto_target > 0:
		_aggressive_status(true)
		direction = last_position.normalized()
	else:
		_aggressive_status(false)
	
	return direction

func _aggressive_status(status: bool) -> void:
	if status == true:
		$HealthBar.visible = true
	else:
		$HealthBar.visible = false
		
		

func _on_damage_area_body_entered(body: Node2D) -> void:
	if body.name == 'Player' and not body.is_disabled:
		body.take_damage(_damage)
		body.knockback(self,400)
	#$CollisionShape2D.set_deferred("disabled", true)
