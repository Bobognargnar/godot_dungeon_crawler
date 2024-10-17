extends Area2D

@export var loot_item: Resource = null


func _ready() -> void:
	var loot_type = loot_item.instantiate()
	
	$Sprite.texture = loot_type.get_node("Sprite").texture
	$Sprite.region_enabled = loot_type.get_node("Sprite").region_enabled
	if $Sprite.region_enabled:
		$Sprite.set_region_rect(loot_type.get_node("Sprite").get_region_rect())
		
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	""" Remove object and equip item """
	if body.name == 'Player': # Only player can pickup weapons
		var loot_type = loot_item.instantiate()
		# Each type of object applies a different type of effect.
		# Weapons get equipped, for example
		loot_type.apply_effect(body)
		queue_free()
