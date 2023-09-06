class_name Station
extends Node3D

@onready var player_position: Node3D = $"PlayerPosition"

func get_player_position() -> Node3D:
	return player_position

func activate():
	pass

func deactivate():
	pass
