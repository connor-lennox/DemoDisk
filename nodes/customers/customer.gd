class_name Customer
extends Node3D

const MECH_MODELS = [
	"res://assets/mechs/George.gltf", "res://assets/mechs/Leela.gltf", "res://assets/mechs/Mike.gltf", "res://assets/mechs/Stan.gltf"
]

const WALK_SPEED = 2.5
const ROTATION_SPEED = 2

signal finished_moving
signal finished_rotating

@onready var character_root: Node3D = $CharacterRoot

var mech: Node3D
var mech_animator: AnimationPlayer
var order: Order

var walking: bool = false
var movement_target: Vector3

var rotating: bool = false
var rotation_target: float


# Called when the node enters the scene tree for the first time.
func _ready():
	mech = load(MECH_MODELS.pick_random()).instantiate()
	mech_animator = mech.get_node("AnimationPlayer")
	character_root.add_child(mech)
	mech_animator.play("Idle", 0.5)


func _process(delta: float):
	_walk(delta)
	_rotate(delta)

func _walk(delta):
	if not walking:
		return
	
	position = position.move_toward(movement_target, WALK_SPEED * delta)
	if position.is_equal_approx(movement_target):
		walking = false
		mech_animator.play("Idle", 0.5)
		finished_moving.emit()

func _rotate(delta):
	if not rotating:
		return

	rotation.y = move_toward(rotation.y, rotation_target, ROTATION_SPEED * delta)
	if is_equal_approx(rotation.y, rotation_target):
		rotating = false
		finished_rotating.emit()


func move_to_position(target: Vector3):
	walking = true
	movement_target = target
	mech_animator.play("Walk", 0.5)

func rotate_to_angle_degrees(target: float):
	rotating = true
	rotation_target = deg_to_rad(target)
