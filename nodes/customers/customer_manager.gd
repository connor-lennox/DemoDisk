class_name CustomerManager
extends Node3D

const LINE_SPACING = 1.3
const BACK_OF_LINE = 10
const WALK_FORWARD_DELAY = 1

var entrees = [
		preload("res://items/resources/burger_cheese_item.tres"), 
		preload("res://items/resources/burger_deluxe_item.tres"), 
		preload("res://items/resources/burger_plain_item.tres")
	]

var customer_scene = preload("res://nodes/customers/customer.tscn")

var active_customer: Customer = null
var customers: Array[Customer] = []


func _ready():
	for i in range(1, 4):
		await get_tree().create_timer(2).timeout
		spawn_customer()


func spawn_customer():
	var new_customer: Customer = customer_scene.instantiate() as Customer
	new_customer.order = _construct_order()
	new_customer.interactable = false
	
	add_child(new_customer)
	new_customer.position = position - global_transform.basis.z * BACK_OF_LINE
	new_customer.call_deferred("move_to_position", _get_customer_stand_position(len(customers)))
	
	customers.append(new_customer)
	
	if active_customer == null:
		_set_active_customer(new_customer)

func pop_customer():
	var customer: Customer = customers.pop_front()
	if customer == null:
		return
	
	_remove_customer(customer)
	
	await get_tree().create_timer(WALK_FORWARD_DELAY).timeout
	for i in range(len(customers)):
		customers[i].move_to_position(_get_customer_stand_position(i))
	
	if len(customers) > 0:
		_set_active_customer(customers[0])


func _remove_customer(customer: Customer):
	customer.rotate_to_angle_degrees(90)
	await customer.finished_rotating
	customer.move_to_position(customer.position + customer.global_transform.basis.z * 2)
	await customer.finished_moving
	customer.rotate_to_angle_degrees(180)
	await customer.finished_rotating
	customer.move_to_position(customer.position + customer.global_transform.basis.z * 10)
	await customer.finished_moving
	
	customer.queue_free()


func _get_customer_stand_position(customer_idx: int):
	return position - global_transform.basis.z * LINE_SPACING * customer_idx

func _set_active_customer(customer: Customer):
	active_customer = customer
	active_customer.interactable = true
	customer.order_satisfied.connect(pop_customer)

func _construct_order() -> Order:
	return Order.new([entrees.pick_random()])
