extends Node

func _switch_to_scene(path: String):
	get_tree().get_first_node_in_group("scene_holder").switch_to_scene(path)


func switch_to_title():
	_switch_to_scene("res://scenes/title/title_scene.tscn")

func switch_to_game():
	_switch_to_scene("res://scenes/level/level_scene.tscn")

func switch_to_tutorial():
	_switch_to_scene("res://scenes/tutorial/tutorial_scene.tscn")
