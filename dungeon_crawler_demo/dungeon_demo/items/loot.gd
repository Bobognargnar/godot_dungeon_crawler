extends Area2D

@export var loot_item: Resource = null
@export var key_id: int = 0
@export var loot_name: String = ''

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
		
		$Sprite.hide()
		set_collision_layer_value(1,0)
		set_collision_mask_value(1,0)
		
		# Keys are managed like so, for now
		if "key_id" in loot_type:
			loot_type.key_id = key_id

		# Show and animate loot name
		var popup_text = loot_type.name
		if loot_name != '': 
			popup_text = loot_name
			loot_type.name = loot_name
		$LootIndicator.animate(popup_text,20,1)
		
		loot_type.apply_effect(body)
		
		

func _on_loot_indicator_popup_finished() -> void:
	queue_free()
