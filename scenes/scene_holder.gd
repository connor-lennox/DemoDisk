extends Node

@onready var fade_transition = $FadeTransition
@onready var scene_root = $SceneRoot

func switch_to_scene(path: String):
	await fade_transition.cover()
	
	for child in scene_root.get_children():
		child.queue_free()
	
	var new_scene = load(path).instantiate()
	scene_root.add_child(new_scene)
	
	fade_transition.uncover()
