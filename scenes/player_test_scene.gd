extends Node3D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _ready():
	$TestItem2.food_type = load("res://items/resources/hotdog_item.tres")
	$TestItem4.food_type = load("res://items/resources/burger_patty_raw_item.tres")
	$PlateItem2.dirty = false
	$PlateItem.dirty = true
	$PlateItem3.dirty = true
