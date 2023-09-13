extends Node3D

func _process(delta):
	global_rotation.y += delta * 0.1
