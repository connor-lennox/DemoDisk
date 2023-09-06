class_name FoodItem
extends Item

var food_type: FoodItemType = null: set = _set_food_type

func _set_food_type(new_food_type):
	food_type = new_food_type
	if food_type != null:
		_set_mesh(food_type.mesh)
	else:
		_set_mesh(null)
