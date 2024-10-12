extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	""" Remove object and equip item """
	if body.name == 'Player': # Only player can pickup weapons
		var sword_texture = preload("res://.godot/imported/weapon_red_gem_sword.png-ad2e5ed9db3deebf97cd818cb7209a7c.ctex")
		body.equip_weapon(sword_texture)
		hide()
