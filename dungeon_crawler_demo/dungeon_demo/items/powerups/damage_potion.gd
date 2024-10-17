extends Area2D

""" Potion can be consumed at later time from inventory """
@export var hp_gain = 10

func apply_effect(player: Node2D) -> void:
	player.move_to_inventory(self)

func use_item(player: Node2D) -> void:
	print("Using item " + name)
	#player.take_damage(-hp_gain) # negative damage is healing :D
	player.remove_from_inventory(self)
	queue_free() # after consumption, effect disappears
	pass
