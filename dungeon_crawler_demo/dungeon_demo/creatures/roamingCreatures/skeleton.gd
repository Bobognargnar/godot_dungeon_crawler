extends RoamingCreature

@export var damage = 5

func _on_damage_area_body_entered(body: Node2D) -> void:
	if body.name == 'Player':
		body.take_damage(damage)
	#$CollisionShape2D.set_deferred("disabled", true)
