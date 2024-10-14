extends Node

var score

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func manage_player_health(dam_perc: float) -> void:
	var hp_left = $Hud.update_health_bar(dam_perc)
	if hp_left <= 0:
		game_over()
	pass

func game_over() -> void:
	$Hud.show_game_over()
	$Player.hide()
	
func new_game():
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$Hud.show_message("Get Ready")


func _on_player_stamina_change(stam: float) -> void:
	$Hud.update_stamina_bar(stam)
