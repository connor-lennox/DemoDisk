extends Node3D

const door_open_rotation = Vector3(0, 105, 0)
const door_closed_rotation = Vector3.ZERO


@onready var fridge_door = $Fridge_Door
var _door_tween: Tween

@onready var open_sfx = $OpenSfx
@onready var close_sfx = $CloseSfx

# station_element functions
func station_activated():
	_open_door()

func station_deactivated():
	_close_door()


func _open_door():
	_move_door(door_open_rotation)
	open_sfx.play()

func _close_door():
	await _move_door(door_closed_rotation)
	close_sfx.play()

func _move_door(new_rotation: Vector3):
	if _door_tween:
		_door_tween.kill()
	_door_tween = get_tree().create_tween()
	_door_tween.tween_property(fridge_door, "rotation_degrees", new_rotation, 0.3) \
		.set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_QUAD)
	await _door_tween.finished
