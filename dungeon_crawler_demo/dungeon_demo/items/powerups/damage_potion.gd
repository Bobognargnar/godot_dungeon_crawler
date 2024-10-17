extends Area2D

""" Potion can be consumed at later time from inventory """
@export var modifier = 10
@export var duration = 10 #seconds

var inventory_owner = null

func apply_effect(player: Node2D) -> void:
	inventory_owner = player
	player.move_to_inventory(self)

func use_item() -> void:
	print("Using item " + name)
	inventory_owner.apply_modifier("damage",modifier,duration)
	inventory_owner.remove_from_inventory(self)
	queue_free() # after consumption, effect disappears
	pass
