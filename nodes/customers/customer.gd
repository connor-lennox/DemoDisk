class_name Customer
extends Area3D

const ORDER_ICON_SPRITE_SCENE = preload("res://nodes/customers/order_icon_sprite.tscn")

const MECH_MODELS = [
	"res://assets/mechs/George.gltf", "res://assets/mechs/Leela.gltf", "res://assets/mechs/Mike.gltf", "res://assets/mechs/Stan.gltf"
]

const GREETINGS = [
	preload("res://assets/sounds/voicelines/give_me_a.wav"), 
	preload("res://assets/sounds/voicelines/hello_can_i_have.wav"), 
	preload("res://assets/sounds/voicelines/id_like_a.wav")
]

const LEAVINGS = [
	preload("res://assets/sounds/voicelines/delicious.wav"), 
	preload("res://assets/sounds/voicelines/thanks.wav"), 
	preload("res://assets/sounds/voicelines/thank_you.wav")
]

const AND_A_VOICE_LINE = preload("res://assets/sounds/voicelines/and_a.wav")

const WALK_SPEED = 2.5
const ROTATION_SPEED = 2

signal finished_moving
signal finished_rotating

signal order_satisfied

@onready var character_root: Node3D = $CharacterRoot
@onready var item_receiver: Node3D = $ItemReceiver
@onready var dialog_player = $DialogPlayer
@onready var order_root = $OrderRoot

var mech: Node3D
var mech_animator: AnimationPlayer

var greeting_line: AudioStream
var leaving_line: AudioStream

var speaking: bool = false
var gave_order: bool = false

var order: Order
var received_items: Array[FoodItemType]

var walking: bool = false
var movement_target: Vector3

var rotating: bool = false
var rotation_target: float

var interactable: bool = true


# Called when the node enters the scene tree for the first time.
func _ready():
	mech = load(MECH_MODELS.pick_random()).instantiate()
	greeting_line = GREETINGS.pick_random()
	leaving_line = LEAVINGS.pick_random()
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


func interact(player: Player):
	# Customers can receive food items either:
	#  1. as a completed recipe on a plate
	#  2. as a loose FoodItem
	# Because recipe construction can only happen on plates,
	# this doesn't remove the need for them. Giving loose FoodItems will
	# only be relevant for "simple" things (drinks, etc.)
	if not interactable:
		return
	
	# If we haven't told our order yet, do that regardless
	if not gave_order:
		_say_order()
		return
	
	if player.currently_held_item is PlateItem:
		var plate_recipe = player.currently_held_item.held_recipe
		if await _try_take(player, plate_recipe):
			return
	
	if player.currently_held_item is FoodItem:
		var food_item = player.currently_held_item.food_type
		if await _try_take(player, food_item):
			return
	
	# If the player isn't holding anything, tell them our order instead
	if player.currently_held_item == null:
		_say_order()
		return

func _try_take(player: Player, food_item: FoodItemType) -> bool:
	if food_item in order.required_food_items() and not food_item in received_items: 
		await _take_item_from_player(player)
		received_items.append(food_item)
		_refresh_order_icons()
		if _check_requirements_satisfied():
			_complete_order()
		return true
	return false


func move_to_position(target: Vector3):
	walking = true
	movement_target = target
	mech_animator.play("Walk", 0.5)

func rotate_to_angle_degrees(target: float):
	rotating = true
	rotation_target = deg_to_rad(target)


func _take_item_from_player(player: Player):
	var item = player.currently_held_item
	player.currently_held_item = null
	item.reparent(item_receiver)
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property(item, "position", Vector3.ZERO, 0.5)
	tween.tween_property(item, "rotation", Vector3.ZERO, 0.5)
	await tween.finished
	item.queue_free()

func _check_requirements_satisfied():
	# Because an order can only contain one of any given item,
	# this is sufficient to state the order is "complete"
	return len(order.requirements) == len(received_items)

func _complete_order():
	_play_dialog_line(leaving_line)
	_clear_order_icons()
	order_satisfied.emit()


func _say_order():
	if speaking:
		return
	
	speaking = true
	await _play_dialog_line(greeting_line)
	if len(order.requirements) == 1:
		# If there's only one order item, just say what it is
		await _play_dialog_line(order.requirements[0].voice_line)
		if not gave_order:
			_add_order_icon(order.requirements[0].icon)
	else:
		# For multiple items, we order as "...X, Y, and a Z"
		for order_item in order.requirements.slice(0, -1):
			await _play_dialog_line(order_item.voice_line)
			if not gave_order:
				_add_order_icon(order_item.icon)
		await _play_dialog_line(AND_A_VOICE_LINE)
		await _play_dialog_line(order.requirements[-1].voice_line)
		if not gave_order:
			_add_order_icon(order.requirements[-1].icon)
	
	speaking = false
	gave_order = true


func _play_dialog_line(line: AudioStream):
	dialog_player.stream = line
	dialog_player.play()
	await dialog_player.finished


func _add_order_icon(icon: Texture, idx=-1):
	# idx -1 is an indicator that we need to infer the position
	var sprite = ORDER_ICON_SPRITE_SCENE.instantiate()
	sprite.texture = icon
	order_root.add_child(sprite)
	if idx == -1:
		idx = len(order_root.get_children()) - 1
	sprite.position = Vector3.DOWN * idx * 0.5

func _clear_order_icons():
	for child in order_root.get_children():
		child.queue_free()

func _refresh_order_icons():
	_clear_order_icons()
	var idx = 0
	for requirement in order.requirements:
		if requirement.food_item not in received_items:
			_add_order_icon(requirement.icon, idx)
			idx += 1
