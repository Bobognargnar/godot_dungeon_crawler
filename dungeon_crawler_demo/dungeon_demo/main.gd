extends Node

var score

var player_scene = preload("res://creatures/Player.tscn")


""" Collision layer convention:
	layer - where I am
	mask - what I see
	
	layer 1 - physical movement on the ground
	layer 2 - line of sight
	layer 3 - presence sensor | things that sense the presence of the player
	
	"""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# Initializing all the creatures to have the player as target.
	var creatures = []
	findByClass(self, "CharacterBody2D", creatures)
	for creature in creatures:
		if creature.name != "Player":
			creature.target = $Player
			
	# TODO - maybe loading level0 here rather than having it in the main? 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Find all nodes of a certain class
func findByClass(node: Node, className : String, result : Array) -> void:
	if node.is_class(className):
		result.push_back(node)
	for child in node.get_children():
		findByClass(child, className, result)

func manage_player_health(dam_perc: float) -> void:
	var hp_left = $Hud.update_health_bar(dam_perc)
	if hp_left <= 0:
		game_over()

func game_over() -> void:
	$Hud.show_game_over()
	#$Player.hide()
	$Player.disable_player()
	
# Called by clicking on START button in HUD
func new_game():
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$Hud.show_message("Get Ready")
	
func lets_go() -> void:
	$Player.enable_player()


func _on_player_stamina_change(stam: float) -> void:
	$Hud.update_stamina_bar(stam)
