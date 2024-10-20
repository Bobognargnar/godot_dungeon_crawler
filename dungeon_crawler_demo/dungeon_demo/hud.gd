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
	$WeaponSlot.hide()
	for s in [1,2,3,4,5]:
		get_node("ItemSlot"+str(s)).hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# When the player has lost health, the yellow bar starts decresing to reach the red bar.
	
	for s in [1,2,3,4,5]:
		var slot = str(s)
		if (Input.is_action_pressed("item_"+slot) and
			get_node("ItemSlot"+slot).get_node("InventoryItem").get_child_count()>0):
			get_node("ItemSlot"+slot).get_node("InventoryItem").get_child(0).use_item()
		
	
	if $HealthBar.value < $HealthBarDelta.value:
		var delta_bar = delta * yellow_bar_speed
		delta_bar = max(delta_bar,$HealthBarDelta.step)
		$HealthBarDelta.value -= delta_bar
		$HealthBarDelta.value = max($HealthBarDelta.value,$HealthBar.value)
			
	# When player has gained health
	if $HealthBar.value < real_health:
		var delta_bar = delta * yellow_bar_speed
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
	$WeaponSlot.show()
	for s in [1,2,3,4,5]:
		get_node("ItemSlot"+str(s)).show()
	
	
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
		var slot_node = get_node("ItemSlot"+str(slot)).get_node("InventoryItem")
		if slot_node and slot_node.get_child_count()==0:
			#print("HUD: adding item to inventory: " + item.name + " slot " + str(slot))
			slot_node.add_child(item)
			break

func add_to_weapons(item: Node2D) -> void:
	var slot_node = get_node("WeaponSlot").get_node("Weapon")
	if not slot_node:
		return
	
	# Remove old weapon
	if slot_node.get_child_count()>0:
		slot_node.remove_child(slot_node.get_child(0))
	
	# Set new weapon
	item.show()
	item.scale = Vector2(0.5,0.5)
	slot_node.call_deferred("add_child",item)
	
	# Display durability in hud
	get_node("WeaponSlot").get_node("Label").text = "100%"
	get_node("WeaponSlot").get_node("Label").show()

func add_to_collection(item: Node2D) -> void:
	""" Add collected item to a new collection slot"""
	var collection_slot = get_node("Collection").get_child(get_node("Collection").get_child_count()-1)
	
	if collection_slot.get_child_count() > 0:
		collection_slot = collection_slot.duplicate()
		collection_slot.remove_child(collection_slot.get_child(0))
		get_node("Collection").add_child(collection_slot)
		collection_slot.position.x += 30
	
	if collection_slot.get_child_count() == 0:
		collection_slot.show()
		collection_slot.add_child(item)
		

func _on_player_update_weapon_durabilit_hud(dur: float) -> void:
	$WeaponSlot/Label.text = str(int(dur*100)) + "%"
	if dur < 0.1:
		var item = get_node("WeaponSlot").get_node("Weapon").get_child(0)
		item.queue_free()
		$WeaponSlot/Label.hide()
