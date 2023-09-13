extends Node3D

const PLATE_RETURN_TIME = 10

@onready var customer_manager: CustomerManager = $CustomerManager
@onready var customer_spawn_timer = $CustomerSpawnTimer
@onready var player = $Player

@onready var sink = $Restaurant/Stations/SinkStation/Sink

# Called when the node enters the scene tree for the first time.
func _ready():
	Bgm.play_game_music()
	_spawn_customer()

func _spawn_customer():
	if len(customer_manager.customers) <= 6:
		customer_manager.spawn_customer()
	customer_spawn_timer.wait_time = randf_range(15, 20)
	customer_spawn_timer.start()

func _order_completed():
	_wait_and_return_plate()

func _wait_and_return_plate():
	await get_tree().create_timer(PLATE_RETURN_TIME).timeout
	sink.generate_dirty_plate()

func _game_over():
	player.locked = true
	await get_tree().create_timer(2).timeout
	SceneManager.switch_to_game_over()
