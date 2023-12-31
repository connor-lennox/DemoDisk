class_name Player
extends Node3D

const TIME_TO_MOVE = 0.3

@onready var camera_rig: Node3D = $"CameraRig"
@onready var camera: Camera3D = $"%Camera"
@onready var interact_raycast: RayCast3D = $"%InteractRaycast"

@export var stations: Array[Station] = []
var current_station: int = 0

var moving: bool = false
var interacting: bool = false
var locked: bool = false

@export var mouse_sens = 0.15
@export var controller_sens = 2.2
var camera_anglev=0

@export var camera_x_limit = 35
@export var camera_y_limit = 30

var currently_held_item: Item = null
@onready var item_attach_point: Node3D = $"%ItemAttachPoint"

@onready var swish_sfx = $SwishSfx


func _ready():
	call_deferred("move_to_station", 0)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _process(_delta):
	if locked or moving:
		return
	
	if Input.is_action_just_pressed("move_right"):
		move_to_station((current_station + 1) % len(stations))
	if Input.is_action_just_pressed("move_left"):
		move_to_station(current_station - 1 if current_station > 0 else len(stations) - 1)
	
	# Input of "down" moves you two, which is a 180 degree turn with 4 stations
	if Input.is_action_just_pressed("move_back"):
		move_to_station(current_station - 2 if current_station > 1 else len(stations) - (2 - current_station))
	if Input.is_action_just_pressed("interact") and not interacting:
		try_interact()
	
	
	# Process controller-driven rotation
	var controller_rotation = Input.get_vector("rotate_right", "rotate_left", "rotate_down", "rotate_up").normalized() * controller_sens
	
	camera_rig.rotate_y(deg_to_rad(controller_rotation.x))
	camera_rig.rotate_object_local(Vector3.RIGHT, deg_to_rad(controller_rotation.y))
	camera_rig.rotation_degrees.y = clamp(camera_rig.rotation_degrees.y, -camera_x_limit, camera_x_limit)
	camera_rig.rotation_degrees.x = clamp(camera_rig.rotation_degrees.x, -camera_y_limit, camera_y_limit)


func _input(event):
	if event is InputEventMouseMotion and not locked:
		camera_rig.rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		var changev = -event.relative.y * mouse_sens
		if camera_anglev + changev > -50 and camera_anglev + changev < 50:
			camera_anglev += changev
			camera_rig.rotate_object_local(Vector3.RIGHT, deg_to_rad(changev))
		
		# Counterintuitively, the y component of the rotation gets the x limit.
		camera_rig.rotation_degrees.y = clamp(camera_rig.rotation_degrees.y, -camera_x_limit, camera_x_limit)
		camera_rig.rotation_degrees.x = clamp(camera_rig.rotation_degrees.x, -camera_y_limit, camera_y_limit)


func move_to_station(station_number: int):
	# Setting this to true blocks us from moving while mid-move
	moving = true
	
	# Deactivate the current station before we leave to avoid interactions
	stations[current_station].deactivate()
	
	# Activate the new station
	current_station = station_number
	stations[current_station].activate()
	
	swish_sfx.play()
	
	# Tween player position and rotation to align with target station
	var target: Node3D = stations[current_station].get_player_position()
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", target.global_position, TIME_TO_MOVE)
	var rotation_target = Vector3(0, global_rotation.y + wrapf(target.global_rotation.y - global_rotation.y, -PI, PI), 0)
	tween.parallel().tween_property(self, "global_rotation", rotation_target, TIME_TO_MOVE)
	
	# Stop "moving" and activate the current station
	tween.tween_callback(self.set.bind("moving", false))


func try_interact():
	var col = interact_raycast.get_collider()
	if col != null:
		interacting = true
		await col.interact(self)
		interacting = false
		print("interaction done!")
