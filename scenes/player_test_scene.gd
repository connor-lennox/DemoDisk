extends Node3D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _ready():
	Bgm.play_game_music()
	
	$TestItem2.food_type = load("res://items/resources/lettuce_whole_item.tres")
	$TestItem4.food_type = load("res://items/resources/tomato_whole_item.tres")
	$PlateItem2.dirty = false
	$PlateItem.dirty = true
	$PlateItem3.dirty = true

	$Customer.order = Order.new([load("res://nodes/customers/order_items/burger_cheese_order_item.tres")])
