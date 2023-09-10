extends Node


func _ready():
	Bgm.play_title_music()


func _start_game():
	SceneManager.switch_to_game()


func _start_tutorial():
	SceneManager.switch_to_tutorial()
