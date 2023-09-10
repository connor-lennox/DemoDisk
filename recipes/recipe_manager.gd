extends Node

const recipe_location = "res://recipes/resources"

var recipes: Array[Recipe] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	for res in DirAccess.get_files_at(recipe_location):
		res = res.replace(".remap", "")
		recipes.append(load(recipe_location + "/" + res))


func get_recipe(items: Array[FoodItemType]) -> Recipe:
	for recipe in recipes:
		if recipe.is_satisfied(items):
			return recipe
	return null


func is_partial_recipe(items: Array[FoodItemType]) -> bool:
	for recipe in recipes:
		if not recipe.is_violated(items):
			return true
	return false
