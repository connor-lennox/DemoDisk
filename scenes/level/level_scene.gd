extends Node3D

const PLATE_RETURN_TIME = 10

@onready var customer_manager: CustomerManager = $CustomerManager

@onready var sink = $Restaurant/Stations/SinkStation/Sink

# Called when the node enters the scene tree for the first time.
func _ready():
	Bgm.play_game_music()
	customer_manager.spawn_customer()
	customer_manager.spawn_customer()


func _order_completed():
	_wait_and_return_plate()


func _wait_and_return_plate():
	await get_tree().create_timer(PLATE_RETURN_TIME).timeout
	sink.generate_dirty_plate()
