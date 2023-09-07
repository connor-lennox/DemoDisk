class_name Item
extends Node3D

@onready var mesh_root = $"MeshRoot"
@onready var collider = $"CollisionShape3D"

var interactable: bool = true: set = _set_interactable

func _set_mesh(mesh_scene: PackedScene):
	# Destroy all our children to prep for the new object
	for child in mesh_root.get_children():
		child.queue_free()
	
	if mesh_scene != null:
		var inst = mesh_scene.instantiate()
		mesh_root.add_child(inst)

func _set_interactable(new_state):
	interactable = new_state
	
	# Enable/disable collision to avoid being picked up while not interactable
	collider.disabled = !interactable

func interact(player: Player):
	# Can't be picked up if the player is currently holding something else
	if player.currently_held_item != null:
		return
	await get_picked_up_by(player)

func get_picked_up_by(player: Player):
	print("%s picked up %s" % [player, self])
	
	# Tell the player we've been picked up
	player.currently_held_item = self
	
	# Once picked up we're not interactable
	interactable = false
	
	# Tween into place
	self.reparent(player.item_attach_point)
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property(self, "position", Vector3.ZERO, 0.5)
	tween.tween_property(self, "rotation", Vector3.ZERO, 0.5)
	await tween.finished
