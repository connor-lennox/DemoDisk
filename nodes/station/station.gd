class_name Station
extends Node3D

@onready var player_position: Node3D = $"PlayerPosition"

func get_player_position() -> Node3D:
	return player_position

func activate():
	for child in get_children():
		if child.is_in_group("station_element"):
			child.station_activated()

func deactivate():
	for child in get_children():
		if child.is_in_group("station_element"):
			child.station_deactivated()
