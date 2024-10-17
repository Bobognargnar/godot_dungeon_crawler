extends Area2D

""" Potion can be consumed at later time from inventory """
@export var hp_gain = 10

var inventory_owner = null

func apply_effect(player: Node2D) -> void:
	inventory_owner = player
	player.move_to_inventory(self)

func use_item() -> void:
	print("Using item " + name)
	inventory_owner.take_damage(-hp_gain) # negative damage is healing :D
	inventory_owner.remove_from_inventory(self)
	queue_free() # after consumption, effect disappears
	pass
