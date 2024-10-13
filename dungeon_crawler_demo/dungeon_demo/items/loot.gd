extends Area2D

@export var loot_item: Resource = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var loot_type = loot_item.instantiate()
	$Sprite.texture = loot_type.get_node("Sprite").texture

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	""" Remove object and equip item """
	if body.name == 'Player': # Only player can pickup weapons
		var loot_type = loot_item.instantiate()
		body.equip_weapon(loot_type)
		queue_free()
