extends Node3D

@export_multiline var description: String
@export var station: Station

func enter():
	if station != null:
		station.activate()

func exit():
	if station != null:
		station.deactivate()
