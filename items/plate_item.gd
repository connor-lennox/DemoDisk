class_name PlateItem
extends Item

var clean_plate_scene = preload("res://assets/restaurant/Plate.glb")
var dirty_plate_scene = preload("res://assets/restaurant/Plate_Dirty.glb")

var ingredients: Array[FoodItem] = []
var dirty: bool = false: set = _set_dirty

func _set_dirty(new_dirty: bool):
	dirty = new_dirty
	_set_mesh(dirty_plate_scene if dirty else clean_plate_scene)
