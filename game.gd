extends Node

@onready var scene_holder = $%SceneHolder

func _ready():
	scene_holder.switch_to_scene("res://scenes/title/title_scene.tscn")
