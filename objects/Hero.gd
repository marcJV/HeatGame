extends Entity

# this is me being lazy
const day = "day"
const night = "night"
const dusk = "dusk"
const dawn = "dawn"

var shaded = false
var picked_up_node = null
onready var hold_position = $sprite/HoldPosition

var temperature: float = 50
var outsideTemp: float = 50
var surroundingDeltaTemp: float = 0

var timeOfDay = ""

var isDead = false

var sprite_mat = null

func _ready():
	add_to_group("timeOfDay")
	
	sprite_mat = $sprite.get_material()
	sprite_mat.set_shader_param("shaded", false);

func _physics_process(delta):
	if(Input.is_action_pressed("quit")):
		Transit.change_scene("res://Main.tscn")
	
	
	if not isDead:
		state_default(delta)

func state_default(delta):
	loop_controls()
	loop_movement()
	loop_overlapping_bodies()
	
	if shaded:
		loop_shaded_heat(delta)
		sprite_mat.set_shader_param("shaded", true);
	else:
		loop_heat(delta, outsideTemp)
		sprite_mat.set_shader_param("shaded", false);
		
	get_parent().get_parent().on_hero_temp_change(temperature)
	
	if isDead:
		return
	elif moveDir == Vector2.ZERO:
		update_animation("Idle")
	else:
		update_animation("Walk")
		
func loop_shaded_heat(delta):
	if timeOfDay == "day" || timeOfDay == "dusk" && outsideTemp > 90:
		loop_heat(delta, outsideTemp * 0.65)
	elif timeOfDay == "day" || timeOfDay == "dusk" && outsideTemp > 50:
		loop_heat(delta, outsideTemp * 0.85)
	else:
		loop_heat(delta, outsideTemp)

func loop_heat(delta, temp):
	var outside = temp + surroundingDeltaTemp
	
	#handling adding battery temp here
	if picked_up_node != null:
		outside += picked_up_node.temp
		
	var diff = abs(outside - temperature)
	
	if temperature > outside:
		temperature = lerp(temperature, outside, delta / 8)
	else:
		temperature = lerp(temperature, outside, delta / 5)
	
		
	if temperature >= 100 || temperature <= 0:
		if temperature >= 100:
			get_parent().get_parent().handle_too_hot()
		else:
			get_parent().get_parent().handle_too_cold()

		handle_death()
		#dawn and dusk have no extra effect on temperature

func handle_death():
	isDead = true
	$animationPlayer.play("Ouch")
	get_parent().get_parent().stop_effects()
	var _timer = Timer.new()
	add_child(_timer)
	
	_timer.connect("timeout", self, "play_fall_noise")
	_timer.set_wait_time(0.5)
	_timer.set_one_shot(true)
	_timer.start()

func play_fall_noise():
	handle_step()
	
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
		
func loop_overlapping_bodies():
	var bodies = $hitBox.get_overlapping_areas()
	
	shaded = false
	surroundingDeltaTemp = 0
	
	for body in bodies:
		if body.collision_layer == 16:
			handle_shade(body)
			shaded = true
			print("shaded")
		
func handle_shade(body):
	var shade = body.get_parent()
	
	if shade.has_method('delta_temp'):
		surroundingDeltaTemp = shade.delta_temp()
	
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
	
	if picked_up_node != null:
		if station.can_attach(picked_up_node):
			hold_position.remove_child(picked_up_node)
			station.attach_pickup(picked_up_node)
			picked_up_node = null
		else:
			error()
			
	elif picked_up_node == null && station.attached_pickup != null:
		if station.can_detach():
			attach_pickup(station.detach_pickup())
		else:
			error()
	
func attach_pickup(pickup):
	picked_up_node = pickup
	picked_up_node.pickup()

	hold_position.add_child(picked_up_node)
