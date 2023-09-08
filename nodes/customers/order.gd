class_name Order
extends Object

# An order is made up of several FoodItemTypes, all of which need to be 
# satisfied to succeed with the order.

var requirements: Array[FoodItemType]

func _init(req: Array[FoodItemType]=[]):
	requirements = req
