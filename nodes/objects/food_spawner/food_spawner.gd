extends Node3D

@onready var food_item_scene = preload("res://items/food_item.tscn")

@export var food_type: FoodItemType

@onready var mesh_spawns: Array[Node] = $MeshParent.get_children()

# Called when the node enters the scene tree for the first time.
func _ready():
	for spawn in mesh_spawns:
		var mesh_inst = food_type.mesh.instantiate()
		spawn.add_child(mesh_inst)


func interact(player: Player):
	if player.currently_held_item == null:
		var food_item: FoodItem = food_item_scene.instantiate() as FoodItem
		food_item.call_deferred("_set_food_type", food_type)
		add_child(food_item)
		await food_item.get_picked_up_by(player)
