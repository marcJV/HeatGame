extends Entity


var picked_up_node = null
onready var hold_position = $sprite/HoldPosition

func _ready():
	pass # Replace with function body.



func _physics_process(delta):
	state_default()

func state_default():
	loop_controls()
	loop_movement()
	
#	if picked_up_node != null:
#		picked_up_node.global_position = $HoldPosition.global_position # + picked_up_node.hold_position.position
		
#		print("hold position ", $HoldPosition.global_position)
#	loop_spritedir()
#	loop_damage()
#	loop_action_button()
#	loop_interact()
	
#	if movedir.length() == 1:
#		ray.cast_to = movedir * 8
	
	if moveDir == Vector2.ZERO:
		update_animation("Idle")
#		push_counter = 0
#	elif is_on_wall() && ray.is_colliding() && !ray.get_collider().is_in_group("nopush") && movedir != Vector2.ZERO:
#		anim_switch("push")
#		push_counter += get_physics_process_delta_time()
	else:
		update_animation("Walk")
#	push_counter = 0

func update_animation(animation: String):
	if $animationPlayer.current_animation != animation:
		$animationPlayer.play(animation)
	
func loop_controls():
	moveDir = Vector2.ZERO
	
	var LEFT = Input.is_action_pressed("LEFT")
	var RIGHT = Input.is_action_pressed("RIGHT")
	var UP = Input.is_action_pressed("UP")
	var DOWN = Input.is_action_pressed("DOWN")
	
	if(Input.is_action_just_pressed("GRAB")):
		if $raycast.is_colliding():
			var node = $raycast.get_collider().get_parent()
			
			if node is Station:
				handle_station()
			elif node is Pickup:
				handle_pickup()
		elif picked_up_node != null:
			handle_drop()
			
		
	moveDir.x = -int(LEFT) + int(RIGHT)
	moveDir.y = -int(UP) + int(DOWN)
	
	if moveDir.x < 0:
		$sprite.scale.x = -1
		
		$raycast.cast_to.x = moveDir.x * 8

	elif moveDir.x > 0:
		$sprite.scale.x = 1
			
		$raycast.cast_to.x = moveDir.x * 8
		
	
func handle_pickup():
	print("in pick up")
	if picked_up_node == null:
		var pickup = $raycast.get_collider().get_parent()
		pickup.get_parent().remove_child(pickup)
		attach_pickup(pickup)
	else:
		print("you can only pick up one thing at a time")
			
func handle_drop():
	if picked_up_node.can_drop():
		hold_position.remove_child(picked_up_node)
		get_parent().add_child(picked_up_node)
		picked_up_node.global_position = hold_position.global_position
		
		if $sprite.scale.x > 0:
			picked_up_node.position.x += 2
		else:
			picked_up_node.position.x -= 6
			
		picked_up_node.drop()
				
		picked_up_node = null
	else:
		print("cannot drop")
	
func handle_station():
	var station = $raycast.get_collider().get_parent()
	
	if picked_up_node != null and station.can_attach(picked_up_node):
		hold_position.remove_child(picked_up_node)
		station.attach_pickup(picked_up_node)
		picked_up_node = null
	elif picked_up_node == null && station.attached_pickup != null:
		attach_pickup(station.detach_pickup())
		
		
	print("in station")
	
func attach_pickup(pickup):
	picked_up_node = pickup
	picked_up_node.pickup()

	hold_position.add_child(picked_up_node)
