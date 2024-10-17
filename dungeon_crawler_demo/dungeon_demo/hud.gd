extends CanvasLayer

signal start_game

var healt_bar_active = false

var yellow_bar_speed = 0.1 # % per second
var real_health = 1.0 # real player health %

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()

func show_game_over():
	show_message("Game Over")
	# Wait until the MessageTimer has counted down.
	await $MessageTimer.timeout
	get_tree().reload_current_scene()
	return
	healt_bar_active = false
	$HealthBar.value = 1.0
	$StaminaBar.value = 1.0
	real_health = 1.0
	$Message.text = "Smite the Undead!"
	$Message.show()
	# Make a one-shot timer and wait for it to finish.
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HealthBar.hide()
	$HealthBarDelta.hide()
	$StaminaBar.hide()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# When the player has lost health, the yellow bar starts decresing to reach the red bar.
	var delta_bar = delta * yellow_bar_speed
	if $HealthBar.value < $HealthBarDelta.value:
		delta_bar = max(delta_bar,$HealthBarDelta.step)
		$HealthBarDelta.value -= delta_bar
		$HealthBarDelta.value = max($HealthBarDelta.value,$HealthBar.value)
			
	# When player has gained health
	if $HealthBar.value < real_health:
		delta_bar = max(delta_bar,$HealthBar.step)
		$HealthBar.value += delta_bar
		$HealthBar.value = min($HealthBar.value,real_health)
		$HealthBarDelta.value = $HealthBar.value
	pass


func _on_start_button_pressed() -> void:
	$StartButton.hide()
	$HealthBar.show()
	$HealthBarDelta.show()
	$StaminaBar.show()
	healt_bar_active = true
	start_game.emit()


func _on_message_timer_timeout() -> void:
	$Message.hide()
	get_parent().lets_go()

func update_stamina_bar(delta_stamina: float) -> void:
	if healt_bar_active:
		$StaminaBar.value += delta_stamina

func update_health_bar(dam_perc: float) -> float:
	if healt_bar_active:
		real_health -= dam_perc
		
		real_health = max(real_health,0)
		real_health = min(real_health,1)
		
		if dam_perc >= 0: # damage
			$HealthBar.value = real_health
		
	return real_health

func add_to_inventory(item: Node2D) -> void:
	var inv_slots = [1,2,3,4]
	for slot in inv_slots:
		var slot_node = get_node("InventoryItem"+str(slot))
		if slot_node and slot_node.get_child_count()==0:
			print("HUD: adding item to inventory: " + item.name + " slot " + str(slot))
			slot_node.add_child(item)
			break
	
	pass
