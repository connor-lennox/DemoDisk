extends Node

@onready var camera_pivot = $CameraPivot

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$MarginContainer/VBoxContainer/PlayButton.call_deferred("grab_focus")
	Bgm.play_title_music()

func _process(delta):
	camera_pivot.global_rotation.y += delta * 0.2

func _start_game():
	SceneManager.switch_to_game()

func _start_tutorial():
	SceneManager.switch_to_tutorial()

func _exit_game():
	get_tree().quit()
