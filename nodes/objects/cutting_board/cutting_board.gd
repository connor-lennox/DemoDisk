extends Area3D

# Time it takes to chop a single thing, in seconds
const TIME_TO_CHOP: float = 1.5

@onready var animation_player = $AnimationPlayer

@onready var item_holder = $ItemHolder
var held_item: FoodItem

var chopping: bool = false
var chop_timer: float = 0
var done_chopping: bool = false


func _ready():
	animation_player.play("put_down")

func _process(delta):
	if not chopping:
		return
	chop_timer -= delta
	if chop_timer <= 0:
		print(held_item)
		held_item.food_type = held_item.food_type.chop_result
		done_chopping = true
		_stop_chopping()


func _start_chopping():
	chopping = true
	done_chopping = false
	chop_timer = TIME_TO_CHOP
	animation_player.play("chop")

func _stop_chopping():
	chopping = false
	animation_player.play("put_down")


func interact(player: Player):
	if player.currently_held_item == null && held_item != null:
		# Either start chopping or give the player the chopped item
		if done_chopping:
			await _give_item_to_player(player)
		else:
			_start_chopping()
	
	elif player.currently_held_item != null && held_item == null:
		# Take item from player
		if player.currently_held_item is FoodItem and player.currently_held_item.food_type.chop_result != null:
			await _take_item_from_player(player)

func _give_item_to_player(player: Player):
	var item: Item = held_item
	held_item = null
	done_chopping = false
	await item.get_picked_up_by(player)

func _take_item_from_player(player: Player):
	var item = player.currently_held_item
	print("%s placed a %s onto %s" % [player, item, self])
	player.currently_held_item = null
	item.reparent(item_holder)
	held_item = item
	done_chopping = false
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property(item, "position", Vector3.ZERO, 0.5)
	tween.tween_property(item, "rotation", Vector3.ZERO, 0.5)
	await tween.finished


# station_element functions
func station_activated():
	pass

func station_deactivated():
	_stop_chopping()
