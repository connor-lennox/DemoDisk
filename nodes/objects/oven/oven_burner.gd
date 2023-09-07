extends Area3D

# Cook time in seconds
const COOK_TIME = 10

@onready var audio: AudioStreamPlayer3D = $"AudioStreamPlayer3D"
@onready var smoke_particles: GPUParticles3D = $SmokeParticles

@onready var item_holder: Node3D = $"ItemHolder"
var held_item: Item = null

# Decrementing timer that tells us when to "cook" the held item
var cook_progress: float = 0


func _process(delta):
	if held_item != null && cook_progress >= 0:
		# Tick down cook timer
		cook_progress -= delta
		# When the timer hits 0 the item is cooked
		if cook_progress <= 0:
			held_item.food_type = held_item.food_type.cook_result
			# If the item can be cooked again (i.e. raw -> cooked -> burnt),
			# start the cooking over so it can continue to progress
			if held_item.food_type.cook_result != null:
				_restart_cooking()


func _restart_cooking():
	cook_progress = COOK_TIME


func interact(player: Player):
	if player.currently_held_item == null && held_item != null:
		# Take the item off the burner
		await _give_item_to_player(player)
	
	elif player.currently_held_item != null && held_item == null:
		# Put an item on the burner, if possible
		if player.currently_held_item is FoodItem and player.currently_held_item.food_type.cook_result != null:
			await _take_item_from_player(player)


func _give_item_to_player(player: Player):
	var item: Item = held_item
	held_item = null
	_set_effects(false)
	var tween = get_tree().create_tween()
	tween.tween_property(item, "position", Vector3.UP * 0.1, 0.1)
	tween.tween_callback(item.get_picked_up_by.bind(player))
	await tween.finished


func _take_item_from_player(player: Player):
	var item = player.currently_held_item
	print("%s placed a %s into %s" % [player, item, self])
	player.currently_held_item = null
	item.reparent(item_holder)
	held_item = item
	var tween = get_tree().create_tween()
	tween.tween_property(item, "position", Vector3.UP * 0.1, 0.5)
	tween.parallel().tween_property(item, "rotation", Vector3.ZERO, 0.5)
	tween.tween_property(item, "position", Vector3.ZERO, 0.1)
	tween.tween_callback(_set_effects.bind(true))
	_restart_cooking()
	await tween.finished


func _set_effects(state: bool):
	audio.playing = state
	smoke_particles.emitting = state
