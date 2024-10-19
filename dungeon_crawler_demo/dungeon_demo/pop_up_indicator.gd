extends Node2D

signal popup_finished

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func animate(text: String, riseY: int, speed: float) -> void:
	# Show and animate loot name
	var loot_instance = $Indicator.duplicate()
	self.add_child(loot_instance)
	loot_instance.show()
	loot_instance.get_child(0).text = text
	var tween = create_tween()
	tween.tween_property(loot_instance, "position", Vector2(loot_instance.position.x,loot_instance.position.y-riseY), speed)
	var mod = loot_instance.modulate
	tween.parallel().tween_property(loot_instance, "modulate", Color(mod.r,mod.g,mod.b,0.1), speed)
	tween.connect("finished", on_tween_finished.bind(loot_instance))

# Delete animated element after the tween is done
func on_tween_finished(animated_element: Node2D) -> void:
	popup_finished.emit()
	animated_element.queue_free()
