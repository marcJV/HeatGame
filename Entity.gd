extends KinematicBody2D

class_name Entity

# ATTRIBUTES
export(int) var SPEED = 70

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
	
