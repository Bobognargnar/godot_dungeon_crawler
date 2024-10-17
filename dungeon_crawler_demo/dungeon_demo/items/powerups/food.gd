extends Area2D

""" Food is consumed immediately for instant health gain """
@export var hp_gain = 10

func apply_effect(player: Node2D) -> void:
	player.take_damage(-hp_gain) # negative damage is healing :D
	queue_free() # after consumption, effect disappears
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
