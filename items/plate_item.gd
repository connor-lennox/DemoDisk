class_name PlateItem
extends Item

var clean_plate_scene = preload("res://assets/restaurant/Plate.glb")
var dirty_plate_scene = preload("res://assets/restaurant/Plate_Dirty.glb")

@onready var food_stack_base = $FoodStackBase
@onready var finished_recipe_base = $FinishedRecipeBase

var ingredients: Array[FoodItem] = []
var dirty: bool = false: set = _set_dirty

var held_recipe: FoodItemType


func _set_dirty(new_dirty: bool):
	dirty = new_dirty
	_set_mesh(dirty_plate_scene if dirty else clean_plate_scene)


func take_food_item_from_player(player: Player):
	var item = player.currently_held_item
	if dirty or not item is FoodItem:
		return
	# TODO: Check if we can even receive this ingredient:
	# Does a valid recipe exist containing everything we have AND this new item?
	if receive_food_item(item):
		player.currently_held_item = null


func receive_food_item(food_item: FoodItem) -> bool:
	# No ingredients allowed on dirty plates!
	if dirty:
		return false
	
	# Get a listing of all the food types currently on the plate
	var food_types: Array[FoodItemType] = []
	for ingredient in ingredients:
		food_types.append(ingredient.food_type)
	
	# And add the new thing for checks
	food_types.append(food_item.food_type)
	
	# Don't let the plate get into an "invalid recipe state"
	if not RecipeManager.is_partial_recipe(food_types):
		return false
	
	ingredients.append(food_item)
	food_item.reparent(food_stack_base)
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property(food_item, "position", Vector3.UP * 0.06 * (len(ingredients) - 1), 0.5)
	tween.tween_property(food_item, "rotation", Vector3.ZERO, 0.5)
	
	var completed_recipe = RecipeManager.get_recipe(food_types)
	if completed_recipe != null:
		print("Completed recipe! %s" % completed_recipe)
		_complete_recipe(completed_recipe)
	else:
		_uncomplete_recipe()
	
	return true


func _complete_recipe(recipe: Recipe):
	# Ok, a recipe has been completed! We need to put its mesh on the plate
	# and hide all the ingredients.
	held_recipe = recipe.result
	
	# Hide all the ingredients by hiding their common root
	food_stack_base.visible = false
	
	# Destroy any previously finished recipe (for multistage recipes)
	for child in finished_recipe_base.get_children():
		child.queue_free()
	
	_smoke_puff()
	
	# Add the new item as a child
	var new_result = recipe.result.mesh.instantiate()
	finished_recipe_base.add_child(new_result)

func _uncomplete_recipe():
	# It is possible we go from "finished" to "unfinished" while makign complex recipes.
	# So, we need to "un-finish" and reset that state.
	held_recipe = null
	
	# Destroy any previously finished recipe
	for child in finished_recipe_base.get_children():
		child.queue_free()
	
	_smoke_puff()
	
	# Show all the ingredients by hiding their common root
	food_stack_base.visible = true


func _smoke_puff():
	pass
