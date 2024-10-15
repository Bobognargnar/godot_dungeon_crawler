extends GenericWeapon

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	damage = 10
	durability = 10
	sprite = preload("res://assets/0x72_DungeonTilesetII_v1.7/0x72_DungeonTilesetII_v1.7/frames/weapon_red_gem_sword.png")
	stamina_cost = 6.0
