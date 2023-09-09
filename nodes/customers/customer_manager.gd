class_name CustomerManager
extends Node3D

const LINE_SPACING = 1.3
const BACK_OF_LINE = 10

var entrees = [
		preload("res://items/resources/burger_cheese_item.tres"), 
		preload("res://items/resources/burger_deluxe_item.tres"), 
		preload("res://items/resources/burger_plain_item.tres")
	]

var customer_scene = preload("res://nodes/customers/customer.tscn")

var customers: Array[Customer] = []


func _ready():
	for i in range(1, 4):
		await get_tree().create_timer(2).timeout
		spawn_customer()


func spawn_customer():
	var new_customer: Customer = customer_scene.instantiate() as Customer
	new_customer.order = _construct_order()
	
	add_child(new_customer)
	new_customer.position = position - global_transform.basis.z * BACK_OF_LINE
	new_customer.call_deferred("move_to_position", position - global_transform.basis.z * LINE_SPACING * len(customers))
	
	customers.append(new_customer)

func _construct_order() -> Order:
	return Order.new([entrees.pick_random()])
