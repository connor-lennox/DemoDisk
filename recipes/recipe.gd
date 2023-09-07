class_name Recipe
extends Resource

@export var ingredients: Array[FoodItemType] = []
@export var result: FoodItemType

func is_satisfied(items: Array[FoodItemType]) -> bool:
	# Array equality without ordering:
	#  1. array sizes are equal
	#  2. every elem in array 1 is found in array 2
	if len(ingredients) != len(items):
		return false
	for required in ingredients:
		if required not in items:
			return false
	return true

func is_violated(items: Array[FoodItemType]) -> bool:
	# Determines if we can't possibly be satisfied by adding more 
	# ingredients to the provided state
	#  1. more items than recipe calls for
	#  2. any items the recipe doesn't call for
	#  3. too many of an item the recipe calls for
	
	# too many items
	if len(ingredients) < len(items):
		return true
	
	# wrong type of items
	for item in items:
		if item not in ingredients:
			return true
	
	# too many of correct item
	# this is the most expensive check, so do it last
	var temp = ingredients.duplicate()
	for item in items:
		if item not in temp:
			return true
		temp.remove_at(temp.find(item))
	
	return false
