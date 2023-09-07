extends Node3D


@onready var customer1: Customer = $Customer1


# Called when the node enters the scene tree for the first time.
func _ready():
	while true:
		customer1.move_to_position(Vector3.FORWARD * -5)
		await customer1.finished_moving
		
		customer1.rotate_to_angle_degrees(180)
		await customer1.finished_rotating
		
		customer1.move_to_position(Vector3.ZERO)
		await customer1.finished_moving
		
		customer1.rotate_to_angle_degrees(0)
		await customer1.finished_rotating
