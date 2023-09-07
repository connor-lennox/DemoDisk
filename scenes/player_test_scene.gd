extends Node3D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _ready():
	$TestItem2.food_type = load("res://items/resources/lettuce_whole_item.tres")
	$TestItem4.food_type = load("res://items/resources/tomato_whole_item.tres")
	$PlateItem2.dirty = false
	$PlateItem.dirty = true
	$PlateItem3.dirty = true
