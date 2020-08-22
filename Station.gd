extends KinematicBody2D

class_name Station

var attached_pickup: Pickup = null

func can_attach(node: Pickup):
	return attached_pickup == null
	
func can_detach():
	return attached_pickup != null

func attach_pickup(pickup: Pickup):
	print("attached item!")
	
	attached_pickup = pickup
	$attachPoint.add_child(attached_pickup)
	
func detach_pickup() -> Pickup:
	print("detached item!")
	
	var pickup = attached_pickup
	
	$attachPoint.remove_child(attached_pickup)
	
	attached_pickup = null
	
	return pickup
