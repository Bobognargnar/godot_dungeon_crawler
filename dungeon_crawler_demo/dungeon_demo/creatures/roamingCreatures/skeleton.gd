extends RoamingCreature

@export var damage = 5

func _on_damage_area_body_entered(body: Node2D) -> void:
	if body.name == 'Player':
		body.take_damage(damage)
		body.knockback(self,400)
	#$CollisionShape2D.set_deferred("disabled", true)
