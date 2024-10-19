extends Node

@export var key_id: int = 0

func apply_effect(player: Node2D) -> void:
	print("I am a key with id " + str(key_id))
	player.move_to_collection(self)
