extends KinematicBody2D

class_name Pickup

onready var hold_position = $holdPosition

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("pickup")
	add_to_group("batteries")
	
func pickup():
	print("picked up")
	$shape.disabled = true
	$pickupZone/shape.disabled = true
	
	position = Vector2.ZERO # + $holdPosition.position
	pass
	
func drop():
	print("dropped")
	$shape.disabled = false
	$pickupZone/shape.disabled = false
