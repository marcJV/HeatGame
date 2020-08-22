extends Station

var fill_rate = 2

func can_attach(node: Pickup):
	return attached_pickup == null && node is Battery
	
func attach_pickup(pickup: Pickup):
	.attach_pickup(pickup)
	
	$sprite.frame = 1
	
	# todo start charging
	
func detach_pickup() -> Pickup:
	var pickup = .detach_pickup()
	
	$sprite.frame = 2
	
	return pickup
	
func _physics_process(delta):
	if attached_pickup != null && attached_pickup is Battery:
		(attached_pickup as Battery).charge += fill_rate * delta
	pass
