extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _back_to_title():
	SceneManager.switch_to_title()
