extends StaticBody2D


# Regions of tilemap for various doors
#@export_enum("single", "double") var door_type = "single"
#@export_enum("horizontal", "vertical") var orientation = "horizontal"

var tile_regions = {
	"open_right": Rect2(160,96,16,32),
	"open_left": Rect2(160,128,16,32),
	"closed": Rect2(112,64,16,32),
	}

@export_enum("open_left","open_right","closed") var default_status = "closed"
var starting_x = 0

var current_status = default_status
var door_disabled = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	starting_x = position.x
	_set_door_status(default_status)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _set_door_status(new_status: String) -> void:
	$Sprite2D.set_region_rect(tile_regions[new_status])
	current_status = new_status
	if new_status == "closed":
		set_collision_layer_value(1,true)
		set_collision_mask_value(1,true)
		set_collision_layer_value(2,true)
		set_collision_mask_value(2,true)
		pass
	else:
		set_collision_layer_value(1,false)
		set_collision_mask_value(1,false)
		set_collision_layer_value(2,false)
		set_collision_mask_value(2,false)
		if default_status == "closed":
			# If door started as closed, it closes again after a while
			$ClosingTimeout.start()
		pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not door_disabled and current_status=="closed":
		door_disabled = true
		if (body.global_position.x > global_position.x):
			print("left")
			position.x = starting_x - 16
			_set_door_status("open_left")
		else:
			print("right")
			_set_door_status("open_right")
		pass

# Door closes itself if necessary
func _on_closing_timeout_timeout() -> void:
	if not door_disabled:
		_set_door_status("closed")
		position.x = starting_x
	else:
		$ClosingTimeout.start()


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		print("area exited " + body.name)
		door_disabled = false
