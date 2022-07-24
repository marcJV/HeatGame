extends Pickup

class_name Battery

var fullyCharged = preload("res://sfx/BatteryCharged1.wav")
var warning = preload("res://sfx/BatteryCharged.wav")
var explosion = preload("res://sfx/Explosion.wav")

export var charge = 0
var temp = 0

var isCharging = false

var attached = false
var destroyed = false
var warned = false
var charged = false

func can_drop():
	# TODO check drop spot for collsion and return false if not possible.
	return true
	
func update_charge(delta):
	if destroyed:
		return
	
	charge += delta
	
	if charge < 0:
		charge = 0
	elif charge > 100:
		charge = 100
		temp += 0.01
		
	if temp >= 20:
		blow_up()

func blow_up():
	$AnimationPlayer.play("explode")
	playVoice(explosion)
	destroyed = true
	charge = 0

func _physics_process(delta):
	if destroyed:
		return
	
	if charge < 20:
		$sprite.frame = 0
	elif charge < 40:
		$sprite.frame = 1
	elif charge < 60:
		$sprite.frame = 2
	elif charge < 80:
		$sprite.frame = 3
	elif charge < 100:
		$sprite.frame = 4
	elif charge >= 100:
		$sprite.frame = 5
		
		$AnimationPlayer.stop()
		
	if charge >= 100 && isCharging && !charged:
		charged = true
		playVoice(fullyCharged)
	elif charge < 100:
		charged = false
		
	if temp >= 13:
		$sprite.modulate = Color(1, 0, 0)
		
		if !warned:
			warned = true
			playVoice(warning)
		
	elif temp >= 5:
		$sprite.modulate = Color(1, 1, 0)
	else:
		$sprite.modulate = Color(1, 1, 1)
		
	if temp < 10:
		warned = false
		
	if !attached and temp > 0:
		temp -= 0.02
		
func playVoice(voice):
	$player.set_stream(voice)
	$player.volume_db = 1
	
	var direction = 1
	
	if randi() % 1 == 1:
		direction = -1
	
	$player.pitch_scale = 1 + direction * (randi() % 3 * 0.1)
	$player.play()

func attached(isAttached):
	if destroyed:
		return
		
	attached = isAttached
	
	if(isAttached):
		pass
	else:
		$AnimationPlayer.stop()

func setCharging(charging):
	if destroyed:
		return
		
	isCharging = charging
		
	if(charging):
		$AnimationPlayer.play("charging")
	else:
		$AnimationPlayer.stop()

func delta_temp():
	return temp
