extends Node2D

var message_queue = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$DialoguePopUp.enable_box() # Dialogue boxes collision zone are disabled by default
	$DialoguePopUp.message_queue = [
		"The old maps were right!\n"+
		"                        I hath found an entrance,\n"+ 
		"                        yet the wall has caved in\n"+ 
		"behind me. I can but go forward.",
		
		"There's no going back, \n"+
		"                      I'll have to destroy \n"+
		"                      all these foul creatures\n"+
		"and lay this castle to ruin.",
		"I must get a weapon\n" +
		"                      first, I lost my sword..."
	]
	
	$sword/DialoguePopUp.message_queue = [
		"Finally! This rusty thing\n"+
		"                      will do, for a start..."
		]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

signal start_dialogue
signal stop_dialogue
# Stop all movement and animations
func _on_start_dialogue() -> void:
	emit_signal("start_dialogue")


func _on_stop_dialogue() -> void:
	emit_signal("stop_dialogue")
