extends Area3D

const ITEM_PICKUP_TIME = 0.25

@onready var item_collector = $ItemCollector

func interact(player: Player):
	if player.currently_held_item == null:
		return
	
	# Take single item from the player
	if player.currently_held_item is FoodItem:
		_take_item_from_player(player)
	
	# Take all items off plate
	if player.currently_held_item is PlateItem:
		_take_plate_items(player.currently_held_item)


func _take_item_from_player(player: Player):
	var item = player.currently_held_item
	player.currently_held_item = null
	item.reparent(item_collector)
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property(item, "position", Vector3.ZERO, ITEM_PICKUP_TIME)
	tween.tween_property(item, "rotation", Vector3.ZERO, ITEM_PICKUP_TIME)
	await tween.finished
	item.queue_free()


func _take_plate_items(plate: PlateItem):
	plate._uncomplete_recipe()
	var tween = get_tree().create_tween().set_parallel()
	for item in plate.ingredients:
		item.reparent(item_collector)
		tween.tween_property(item, "position", Vector3.ZERO, ITEM_PICKUP_TIME)
		tween.tween_property(item, "rotation", Vector3.ZERO, ITEM_PICKUP_TIME)
	await tween.finished
	for item in plate.ingredients:
		item.queue_free()
	plate.ingredients.clear()
