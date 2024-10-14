extends CanvasLayer

signal start_game

var healt_bar_active = false

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()

func show_game_over():
	show_message("Game Over")
	# Wait until the MessageTimer has counted down.
	await $MessageTimer.timeout
	
	healt_bar_active = false
	$HealthBar.value = 1.0
	$StaminaBar.value = 1.0
	$Message.text = "Smite the Undead!"
	$Message.show()
	# Make a one-shot timer and wait for it to finish.
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HealthBar.hide()
	$StaminaBar.hide()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_button_pressed() -> void:
	$StartButton.hide()
	$HealthBar.show()
	$StaminaBar.show()
	healt_bar_active = true
	start_game.emit()


func _on_message_timer_timeout() -> void:
	$Message.hide()

func update_stamina_bar(delta_stamina: float) -> void:
	if healt_bar_active:
		$StaminaBar.value += delta_stamina

func update_health_bar(dam_perc: float) -> float:
	if healt_bar_active:
		$HealthBar.value -= dam_perc
	return $HealthBar.value
