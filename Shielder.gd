extends Station

var charge = 0

const max_charge = 500
var drain_rate = 2
var gameover = false

var zap = preload("res://sfx/zap.wav")

func can_attach(node: Pickup):
	if .can_attach(node) && node is Battery && node.charge >= 100:
		return true
	else:
		if node.charge < 100 && attached_pickup == null:
			$Label.text = "Battery not full"
		elif node.destroyed && attached_pickup == null:
			$Label.text = "Battery is busted!"
		else:
			$Label.text = ""
		
		$Label.modulate = Color(1.0, 1.0, 1.0, 1.0)
		$Tween.interpolate_property($Label, 'modulate', Color(1.0, 1.0, 1.0, 1.0), Color(1.0, 1.0, 1.0, 0.0), 0.5, Tween.TRANS_QUAD, Tween.EASE_OUT, 0.5)
		$Tween.start()

		return false
	
func can_detach():
	return .can_detach() && attached_pickup.destroyed
	
func attach_pickup(pickup: Pickup):
	.attach_pickup(pickup)
	
	$cord.frame = 0
	
	$InUseCollision/shape.disabled = false
	
	if attached_pickup is Battery:
		(attached_pickup as Battery).attached(true)
	
func detach_pickup() -> Pickup:
	var pickup = .detach_pickup()
	
	$cord.frame = 1
	$InUseCollision/shape.disabled = true
	
	if pickup is Battery:
		(pickup as Battery).attached(false)
		
	return pickup
	
func _physics_process(delta):
	if attached_pickup == null || attached_pickup.destroyed:
		return
	
	if attached_pickup is Battery && charge < max_charge:
		if(attached_pickup as Battery).charge > 0:
			(attached_pickup as Battery).update_charge(-drain_rate * delta) 
			charge += drain_rate * delta
		
			play_animation("charging")
		else:
			attached_pickup.blow_up()
			$AnimationPlayer.stop()
	elif charge < max_charge:
		play_animation("stop")
		
	var offset = 0
	if charge < max_charge * 0.333:
		offset = 0
	elif charge < max_charge * 0.666:
		offset = -1
	elif charge < max_charge:
		offset = -2
	else:
		offset = -3
		
	$colorFull.rect_position.y = -12 + offset
	
	if charge >= max_charge && !gameover:
		gameover = true
		print("we need to do the win animation or something")
		get_parent().get_parent().handle_win()
		
		$player.set_stream(zap)
		$player.volume_db = 1
	
		$player.play()
		$AnimationPlayer.stop()
		play_animation("shock", true)


func play_animation(animation, isover = false):
	if gameover:
		return
	
	gameover = isover
	$AnimationPlayer.play(animation)
	pass
#func delta_temp():
#	return -10;
