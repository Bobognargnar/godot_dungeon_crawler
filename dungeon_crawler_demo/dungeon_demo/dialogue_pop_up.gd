extends Node2D
class_name DialoguePopUp

signal stop_dialogue
signal start_dialogue

var message_queue = []
var illumination_regions = {
	"T": {'x':552, 'y':472},
	"D": {'x':552, 'y':88},
	"I": {'x':200, 'y':272}
}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#disable_box()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func show_dialogue(message:String) -> void:
	var initial = illumination_regions[message[0].to_upper()]
	var new_message = '                       ' + message.substr(1,len(message))
	$CanvasLayer/DialogueBox/Letter.region_rect.position.x = initial.x
	$CanvasLayer/DialogueBox/Letter.region_rect.position.y = initial.y
	$CanvasLayer/DialogueBox/Label.text = new_message
	if len(message_queue)>0:
		$CanvasLayer/DialogueBox/Close.text = '>'
	else:
		$CanvasLayer/DialogueBox/Close.set_text("x")
	
	#$DialogueBox.position = get_viewport_rect().size / 2
	$CanvasLayer/DialogueBox.show()

func hide_dialogue() -> void:
	$CanvasLayer/DialogueBox.hide()

func _on_close_dialogue() -> void:
	if len(message_queue)==0:
		destroy_box()
	else:
		show_dialogue(message_queue.pop_at(0))
		#hide_dialogue()
	emit_signal("stop_dialogue")

func disable_box() -> void:
	$DialogueCollision.set_deferred("disabled",true)
	
func destroy_box() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	emit_signal("start_dialogue")
	if len(message_queue)>0:
		show_dialogue(message_queue.pop_at(0))
	disable_box()
	
