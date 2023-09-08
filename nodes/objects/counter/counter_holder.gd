extends Area3D

const ITEM_PICKUP_TIME = 0.25

@onready var item_holder: Node3D = $"ItemHolder"
var held_item: Item = null


func interact(player: Player):
	if player.currently_held_item == null && held_item != null:
		await _give_item_to_player(player)
	elif player.currently_held_item != null && held_item == null:
		await _take_item_from_player(player)
	elif player.currently_held_item is FoodItem && held_item is PlateItem:
		await held_item.take_food_item_from_player(player)

func _give_item_to_player(player: Player):
	var item: Item = held_item
	held_item = null
	await item.get_picked_up_by(player)

func _take_item_from_player(player: Player):
	var item = player.currently_held_item
	print("%s placed a %s onto %s" % [player, item, self])
	player.currently_held_item = null
	item.reparent(item_holder)
	held_item = item
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property(item, "position", Vector3.ZERO, ITEM_PICKUP_TIME)
	tween.tween_property(item, "rotation", Vector3.ZERO, ITEM_PICKUP_TIME)
	await tween.finished
	item.put_down()
