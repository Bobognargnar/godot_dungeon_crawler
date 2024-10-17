extends StaticBody2D


# Regions of tilemap for various doors
#@export_enum("single", "double") var door_type = "single"
#@export_enum("horizontal", "vertical") var orientation = "horizontal"


var tile_regions = {
	"open_down": Rect2(112,64,32,16),
	"open_up": Rect2(112,80,32,16),
	"closed": Rect2(96,96,32,16),
	}

@export_enum("open_up","open_down","closed") var default_status = "closed"

var door_disabled = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_set_door_status(default_status)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _set_door_status(new_status: String) -> void:
	$Sprite2D.set_region_rect(tile_regions[new_status])
	if new_status == "closed":
		set_collision_layer_value(1,true)
		set_collision_mask_value(1,true)
		set_collision_layer_value(2,true)
		set_collision_mask_value(2,true)
		#$Area2D.set_collision_layer_value(1,true)
		#$Area2D.set_collision_mask_value(1,true)
		
		pass
	else:
		set_collision_layer_value(1,false)
		set_collision_mask_value(1,false)
		set_collision_layer_value(2,false)
		set_collision_mask_value(2,false)
		#$Area2D.set_collision_layer_value(1,false)
		#$Area2D.set_collision_mask_value(1,false)
		if default_status == "closed":
			# If door started as closed, it closes again after a while
			$ClosingTimeout.start()
		pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not door_disabled:
		door_disabled = true
		print(body.global_position.y)
		print(get_parent().global_position.y)
		print(body.global_position.y > get_parent().global_position.y)
		if (body.global_position.y > get_parent().global_position.y):
			_set_door_status("open_up")
			print("open up")
		else:
			_set_door_status("open_down")
			print("open down")
		pass

# Door closes itself if necessary
func _on_closing_timeout_timeout() -> void:
	if not door_disabled:
		_set_door_status("closed")
	else:
		$ClosingTimeout.start()


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		print("area exited " + body.name)
		door_disabled = false
