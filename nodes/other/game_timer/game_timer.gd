extends ProgressBar

signal timer_finished

@export var time_seconds: int
@export var running: bool = true

var internal_timer: float


func _ready():
	internal_timer = time_seconds
	max_value = time_seconds

func _process(delta):
	if not running:
		return
	internal_timer -= delta
	value = internal_timer
	if internal_timer <= 0:
		_timer_elapsed()

func _timer_elapsed():
	timer_finished.emit()
	running = false
