extends Area3D

const ITEM_PICKUP_TIME = 0.25

const MAX_PLATES = 3
const CLEAN_TIME = 2

var plate_scene = preload("res://items/plate_item.tscn")

@export var starting_plates = 3

@onready var faucet_particles = $FaucetParticles
@onready var splash_particles = $SplashParticles
@onready var faucet_sound = $FaucetSound

@onready var dirty_plate_holders: Array[Node] = $DirtyPlateHolder.get_children()
@onready var clean_plate_holder: Node3D = $CleanPlateHolder

var dirty_plates: Array[PlateItem] = []
var clean_plates: Array[PlateItem] = []

var cleaning: bool = false
var clean_timer: float = 0

func _ready():
	for i in range(starting_plates):
		generate_clean_plate()

func _process(delta):
	if not cleaning:
		return
	
	clean_timer -= delta
	if clean_timer <= 0:
		_wash_plate()
		if len(dirty_plates) > 0:
			clean_timer = CLEAN_TIME
		else:
			_stop_cleaning()


# station_element functions
func station_activated():
	pass

func station_deactivated():
	# If you leave the station, the sink stops cleaning
	_stop_cleaning()
	_clear_particles()


func interact(player: Player):
	if player.currently_held_item == null:
		# Try and take things out of the sink, or wash things if they're dirty
		# If there are clean plates, we can take one out instead
		if len(clean_plates) > 0:
			await _give_item_to_player(player)
			return true
		
		# If not, start cleaning
		if len(dirty_plates) > 0 and not cleaning:
			print("%s started washing the items in %s" % [player, self])
			_start_cleaning()
			return true
	else:
		# Try and put a dirty plate into the sink
		if player.currently_held_item is PlateItem and player.currently_held_item.dirty == true and len(dirty_plates) < MAX_PLATES:
			await _take_item_from_player(player)
			return true
	
	return false


## Used to generate a dirty plate, for when one is "returned" by a customer
func generate_dirty_plate():
	if len(dirty_plates) < MAX_PLATES:
		var new_plate = plate_scene.instantiate()
		dirty_plates.append(new_plate)
		add_child(new_plate)
		var holder = dirty_plate_holders[len(dirty_plates) - 1]
		new_plate.global_position = holder.global_position
		new_plate.global_rotation = holder.global_rotation
		new_plate.call_deferred("set", "dirty", true)
		new_plate.call_deferred("set", "interactable", false)
		new_plate.put_down()


## Used to generate a clean plate, for setup
func generate_clean_plate():
	var new_plate = plate_scene.instantiate()
	clean_plates.append(new_plate)
	add_child(new_plate)
	new_plate.global_position = clean_plate_holder.global_position + Vector3.UP * 0.05 * (len(clean_plates)-1)
	new_plate.global_rotation = Vector3.ZERO
	new_plate.call_deferred("set", "dirty", false)
	new_plate.call_deferred("set", "interactable", false)
	new_plate.put_down()


func _start_cleaning():
	cleaning = true
	if (clean_timer <= 0):
		clean_timer = CLEAN_TIME
	_set_effects(true)


func _stop_cleaning():
	cleaning = false
	_set_effects(false)


func _set_effects(state: bool):
	faucet_particles.emitting = state
	splash_particles.emitting = state
	faucet_sound.playing = state


func _clear_particles():
	faucet_particles.restart()
	faucet_particles.emitting = false
	splash_particles.restart()
	splash_particles.emitting = false


func _wash_plate():
	var plate = dirty_plates.pop_back()
	plate.dirty = false
	plate.put_down()
	clean_plates.append(plate)
	plate.global_position = clean_plate_holder.global_position + Vector3.UP * 0.05 * (len(clean_plates)-1)
	plate.global_rotation = Vector3.ZERO


func _give_item_to_player(player: Player):
	var item: PlateItem = clean_plates.pop_back()
	await item.get_picked_up_by(player)


func _take_item_from_player(player: Player):
	var item = player.currently_held_item
	print("%s placed a %s into %s" % [player, item, self])
	player.currently_held_item = null
	item.reparent(self)
	dirty_plates.append(item)
	var holder = dirty_plate_holders[len(dirty_plates) - 1]
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property(item, "global_position", holder.global_position, ITEM_PICKUP_TIME)
	tween.tween_property(item, "global_rotation", holder.global_rotation, ITEM_PICKUP_TIME)
	await tween.finished
	item.put_down()
