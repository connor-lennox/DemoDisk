extends Node3D

@onready var customer_manager: CustomerManager = $CustomerManager

# Called when the node enters the scene tree for the first time.
func _ready():
	customer_manager.spawn_customer()
	customer_manager.spawn_customer()
