extends StaticBody2D

var tile_regions = {
	"open_down": Rect2(112,64,32,16),
	"open_up": Rect2(112,80,32,16),
	"open_right": Rect2(160,96,16,32),
	"open_left": Rect2(160,128,16,32),
	"closed": Rect2(96,96,32,16),
	}

@export var key_id: int = 0 # id 0 means not locked
@export_enum("left_right","up_down") var opening = "left_right"
@export_enum("open_up","open_down","closed") var default_status = "closed"
var current_status = default_status
var starting_x = 0
var door_disabled = false
var bodies_in_the_way = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tile_regions["closed"] = $Sprite2D.get_region_rect()
	starting_x = position.x
	_set_door_status(default_status)
	
func _set_door_transparent(flag: bool) -> void:
	set_collision_layer_value(2,not flag)
	set_collision_mask_value(2,not flag)

func _set_door_traversable(flag: bool) -> void:
	set_collision_layer_value(1,not flag)
	set_collision_mask_value(1,not flag)

func _set_door_status(new_status: String) -> void:
	$Sprite2D.set_region_rect(tile_regions[new_status])
	current_status = new_status
	if new_status == "closed":
		_set_door_traversable(false)
		_set_door_transparent(false)
	else:
		_set_door_traversable(true)
		_set_door_transparent(true)
		if default_status == "closed":
			# If door started as closed, it closes again after a while
			$ClosingTimeout.start()

func _can_he_open_me(body: Node2D) -> bool:
	if door_disabled:
		return false
	
	if not body.can_open_doors:
		return false
	
	if key_id == 0:
		return true
	
	if "collection" in body:
		for key in body.collection:
			if "key_id" in key and key.key_id == key_id:
				var msg = "Used " + key.name
				$PopUpIndicator.animate(msg,20,1)
				key_id = 0
				return true
		var msg = "Is Locked!"
		$PopUpIndicator.animate(msg,20,1)
	
	return false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body in bodies_in_the_way:
		bodies_in_the_way[body] = true
		
	if _can_he_open_me(body):
		door_disabled = true
		
		if opening == "up_down":
			if (body.global_position.y > get_parent().global_position.y):
				_set_door_status("open_up")
			else:
				_set_door_status("open_down")
			pass
		if opening == "left_right":
			if (body.global_position.x > global_position.x):
				position.x = starting_x - 16
				_set_door_status("open_left")
			else:
				_set_door_status("open_right")
			pass

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body in bodies_in_the_way:
		bodies_in_the_way.erase(body)
	if len(bodies_in_the_way)==0:
		door_disabled = false

# Door closes itself if necessary
func _on_closing_timeout_timeout() -> void:
	if not door_disabled:
		_set_door_status("closed")
		position.x = starting_x
	else:
		$ClosingTimeout.start()
