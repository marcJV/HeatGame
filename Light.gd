extends Station

var drain_rate = 1
var isOff = true

func can_attach(node: Pickup):
	return .can_attach(node) && node is Battery
	
func attach_pickup(pickup: Pickup):
	.attach_pickup(pickup)
	
	$sprite.frame = 0
	
	$InUseCollision/shape.disabled = false
	$heatArea/shape.disabled = false
	
func detach_pickup() -> Pickup:
	var pickup = .detach_pickup()
	
	if (pickup as Battery).charge > 0:
		$AnimationPlayer.play("flicker-off")
		
	isOff = true
	
	$sprite.frame = 1
	$InUseCollision/shape.disabled = true
	$heatArea/shape.disabled = true
	return pickup
	
func _physics_process(delta):
	if attached_pickup != null && attached_pickup is Battery:
		var charge = (attached_pickup as Battery).charge
		
		charge -= drain_rate * delta
		
		if charge <= 0:
			charge = 0
			$AnimationPlayer.play("off")
		
		elif charge > 10:
			if $AnimationPlayer.current_animation != "on" && isOff:
				$AnimationPlayer.play("on")
				isOff = false
				
				print("light is now on")
			$light.energy = 1;

		elif charge > 0:
			if $AnimationPlayer.current_animation != "flicker":
				$AnimationPlayer.play("flicker")
				
				print("flickering")
		elif not isOff:
				$AnimationPlayer.play("off")
				
				print("light is now off")
				
				isOff = true
	
		print("current charge: ", charge)
		(attached_pickup as Battery).charge = charge
			
func delta_temp():
	if attached_pickup != null && attached_pickup is Battery:
		var charge = (attached_pickup as Battery).charge
		if charge > 10:
			return 40
		elif charge > 0:
			return 10
		
	return 0 
