extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func execute() -> void:
	#print("Executing behaviour")
	var target = get_parent().target
	if target and "global_position" in target:
		var player_position = $RayCast2D.to_local(target.global_position)
		$RayCast2D.set_target_position(player_position)
		if ($RayCast2D.is_colliding() and 
			$RayCast2D.get_collider() and 
			$RayCast2D.get_collider().name=='Player'):
			
			var origin = $RayCast2D.global_transform.origin
			var collision_point = $RayCast2D.get_collision_point()
			var distance = origin.distance_to(collision_point)
			
			if (distance < 30.0):
				print("Attack!")
