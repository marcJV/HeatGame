extends KinematicBody2D

class_name Entity

var stepOne = preload("res://sfx/step1.wav")
var stepTwo = preload("res://sfx/step2.wav")
var stepThree = preload("res://sfx/step3.wav")
var stepFour = preload("res://sfx/step4.wav")
var stepFive = preload("res://sfx/step5.wav")
var error = preload("res://sfx/error.wav")

var stepCD = 0
var stepTime = 20

# ATTRIBUTES
export(int) var SPEED = 65

# MOVEMENT
var moveDir = Vector2(0,0)
var knockdir = Vector2(0,0)
var spritedir = "Left"
var last_movedir = Vector2(0,1)

var hitstun = 0;

var state = "default"

onready var anim = $animationPlayer
onready var sprite = $sprite

func loop_movement():
	# find last sprite direction
	var motion
	
	if hitstun == 0:
		motion = moveDir.normalized() * SPEED
	else:
		motion = knockdir.normalized() * 125
	
	move_and_slide(motion)
	
	if moveDir != Vector2.ZERO:
		last_movedir = moveDir
		
		stepCD += 1
	
		if stepCD >= stepTime:
			stepCD = 0
			handle_step()

func error():
	play_voice(error)

func handle_step():
	var voice
	match randi() % 4:
		0:
			voice = stepOne
		1:
			voice = stepTwo
		2:
			voice = stepThree
		3:
			voice = stepFour
		4:
			voice = stepFive
		
	play_voice(voice)
	
func play_voice(voice):
	$player.set_stream(voice)
	$player.volume_db = 1
	
	var direction = 1
	
	if randi() % 1 == 1:
		direction = -1
	
	$player.pitch_scale = 1 + direction * (randi() % 3 * 0.1)
	$player.play()
	
