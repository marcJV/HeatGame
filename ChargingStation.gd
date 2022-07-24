extends Station

var fill_rate = 1.5
var timeOfDay = "day"

func _ready():
	add_to_group("timeOfDay")

func can_attach(node: Pickup):
	return .can_attach(node) && node is Battery
	
func attach_pickup(pickup: Pickup):
	.attach_pickup(pickup)
	
	$sprite.frame = 1
	
	$InUseCollision/shape.disabled = false
	
	if attached_pickup is Battery:
		attached_pickup.attached(true)
		pickup.setCharging(true)
	
func detach_pickup() -> Pickup:
	var pickup = .detach_pickup()
	
	$sprite.frame = 2
	$InUseCollision/shape.disabled = true
	
	if pickup is Battery:
		(pickup as Battery).attached(false)
		
	return pickup
	
func _physics_process(delta):
	if attached_pickup != null && attached_pickup is Battery && timeOfDay != "night":
		(attached_pickup as Battery).update_charge(fill_rate * delta)
		
	if attached_pickup != null && timeOfDay == "night":
		attached_pickup.setCharging(false)
	elif attached_pickup != null:
		attached_pickup.setCharging(true)

func delta_temp():
	return 0;
