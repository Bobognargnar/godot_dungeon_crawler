extends Area2D

@export var damage = 10
@export var durability = 5
@export var sprite = preload("res://assets/0x72_DungeonTilesetII_v1.7/0x72_DungeonTilesetII_v1.7/frames/weapon_red_gem_sword.png")

enum state {ATTACK,WAIT,IDLE,RETURN}
var current_state = state.IDLE
var state_tween: Tween = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if current_state == state.ATTACK:
		#print("process is attack!")
		pass
		
	if current_state == state.ATTACK and state_tween and not state_tween.is_running():
		#print("Stopping attack")
		current_state == state.WAIT
		#state_tween.tween_property(self, "rotation", 0, 1.0)
		pass
	
	
	pass

func attack_animation() -> void:
	state_tween = create_tween()
	state_tween.tween_property(self, "rotation", 1, 1.0)
	await state_tween.finished
	state_tween.stop()
	state_tween.tween_property(self, "rotation", -1, 1.0)
	
	return
	if current_state == state.ATTACK:
		print("Return")
		return
	current_state = state.ATTACK
	
	print("I am being used to attack someone! How debasing!")
	state_tween = create_tween()
	state_tween.tween_property(self, "rotation", 1, 1.0)

	pass
