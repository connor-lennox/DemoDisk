extends Area3D

const MAX_PLATES = 3
const CLEAN_TIME = 3

@onready var dirty_plate_holders: Array[Node] = $DirtyPlateHolder.get_children()
@onready var clean_plate_holder: Node3D = $CleanPlateHolder

var dirty_plates: Array[PlateItem] = []
var clean_plates: Array[PlateItem] = []

var cleaning: bool = false
var clean_timer: float = 0

func _process(delta):
	if not cleaning:
		return
	
	clean_timer -= delta
	if clean_timer <= 0:
		_wash_plate()
		if len(dirty_plates) > 0:
			clean_timer = CLEAN_TIME
		else:
			_stop_cleaning()


func interact(player: Player):
	if player.currently_held_item == null:
		# Try and take things out of the sink, or wash things if they're dirty
		if len(dirty_plates) > 0 and not cleaning:
			print("%s started washing the items in %s" % [player, self])
			_start_cleaning()
			return true
		
		# If there are clean plates, we can take one out instead
		if len(clean_plates) > 0:
			_give_item_to_player(player)
			return true
	else:
		# Try and put a dirty plate into the sink
		if player.currently_held_item is PlateItem and player.currently_held_item.dirty == true and len(dirty_plates) < MAX_PLATES:
			_take_item_from_player(player)
			return true
	
	return false


func _start_cleaning():
	# TODO: enable effects
	cleaning = true
	clean_timer = CLEAN_TIME


func _stop_cleaning():
	# TODO: disable effects
	cleaning = false


func _wash_plate():
	var plate = dirty_plates.pop_back()
	plate.dirty = false
	clean_plates.append(plate)
	plate.global_position = clean_plate_holder.global_position + Vector3.UP * 0.05 * (len(clean_plates)-1)
	plate.global_rotation = Vector3.ZERO


func _give_item_to_player(player: Player):
	var item: PlateItem = clean_plates.pop_back()
	item.get_picked_up_by(player)


func _take_item_from_player(player: Player):
	var item = player.currently_held_item
	print("%s placed a %s into %s" % [player, item, self])
	player.currently_held_item = null
	item.reparent(self)
	dirty_plates.append(item)
	var holder = dirty_plate_holders[len(dirty_plates) - 1]
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property(item, "global_position", holder.global_position, 0.5)
	tween.tween_property(item, "global_rotation", holder.global_rotation, 0.5)
