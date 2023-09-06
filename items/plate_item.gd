class_name PlateItem
extends Item

var clean_plate_scene = preload("res://assets/restaurant/Plate.glb")
var dirty_plate_scene = preload("res://assets/restaurant/Plate_Dirty.glb")

@onready var food_stack_base = $FoodStackBase

var ingredients: Array[FoodItem] = []
var dirty: bool = false: set = _set_dirty

func _set_dirty(new_dirty: bool):
	dirty = new_dirty
	_set_mesh(dirty_plate_scene if dirty else clean_plate_scene)


func take_food_item_from_player(player: Player):
	var item = player.currently_held_item
	if dirty or not item is FoodItem:
		return
	# TODO: Check if we can even receive this ingredient:
	# Does a valid recipe exist containing everything we have AND this new item?
	receive_food_item(item)
	player.currently_held_item = null


func receive_food_item(food_item: FoodItem):
	# No ingredients allowed on dirty plates!
	if dirty:
		return
	
	ingredients.append(food_item)
	food_item.reparent(food_stack_base)
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property(food_item, "position", Vector3.UP * 0.06 * (len(ingredients) - 1), 0.5)
	tween.tween_property(food_item, "rotation", Vector3.ZERO, 0.5)

