class_name FoodItemType
extends Resource

# This is a PackedScene because of how the gltfs are imported.
@export var mesh: PackedScene

# If these is null, the item cannot be processed in that way.
@export var cook_result: FoodItemType
@export var chop_result: FoodItemType
