class_name Order
extends Object

# An order is made up of several FoodItemTypes, all of which need to be 
# satisfied to succeed with the order.

var requirements: Array[OrderItem]

func _init(req: Array[OrderItem]=[]):
	requirements = req

func required_food_items():
	return requirements.map(func(r): return r.food_item) as Array[FoodItemType]
