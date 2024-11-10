extends Node

var score

var player_scene = preload("res://creatures/Player.tscn")
@export var level = 0

var levels = {0:preload("res://Level0.tscn")}

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
			
	# Loading level here
	var Level = levels[level].instantiate()
	Level.set_name("Level")
	self.add_child(Level)
	
	# Connect to dialogue manager
	var dialogueBoxes = []
	findDialogues(self,dialogueBoxes)
	for dialogue in dialogueBoxes:
		dialogue.start_dialogue.connect(_on_dialogue_started)
		dialogue.stop_dialogue.connect(_on_dialogue_stopped)
	

func _on_dialogue_started() -> void:
	var creatures = []
	findByClass(self, "CharacterBody2D", creatures)
	for creature in creatures:
		print(creature.name)
		creature.can_move = false
		print(creature.can_move)

func _on_dialogue_stopped() -> void:
	var creatures = []
	findByClass(self, "CharacterBody2D", creatures)
	for creature in creatures:
		print(creature.name)
		creature.can_move = true
		print(creature.can_move)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Find all nodes of a certain class
func findByClass(node: Node, className : String, result : Array) -> void:
	if node.is_class(className):
		result.push_back(node)
	for child in node.get_children():
		findByClass(child, className, result)

func findDialogues(node: Node, result : Array) -> void:
	if node is DialoguePopUp:
		result.push_back(node)
	for child in node.get_children():
		findDialogues(child, result)

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
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	#$Player.start($StartPosition.position)
	var Level = get_node("Level")
	$Player.start(Level.get_node("StartPosition").position)
	
	$StartTimer.start()
	$Hud.show_message("Get Ready")
	
func lets_go() -> void:
	$Player.enable_player()
	# Enable level dialogue triggers
	var dialogues = []
	findByClass(self, "DialoguePopUp", dialogues)
	print("....")
	print(dialogues)
	for dialogue in dialogues:
		print(dialogue)
		dialogue.get_node("DialogueTrigger").disabled = false


func _on_player_stamina_change(stam: float) -> void:
	$Hud.update_stamina_bar(stam)

func _on_player_move_to_inventory_hud(item: Node2D) -> void:
	$Hud.add_to_inventory(item)

func _on_player_move_to_collection_hud(item: Node2D) -> void:
	$Hud.add_to_collection(item)


func _on_player_move_to_weapons_hud(item: Node2D) -> void:
	$Hud.add_to_weapons(item)
