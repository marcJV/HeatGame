extends Node2D

onready var timeLabel = $CanvasLayer/time
onready var tempLabel = $CanvasLayer/temp

onready var hero = $sortedSprites/Hero

var currentLightColor = Color(1.0, 1.0, 1.0, 1.0)
var darkColor = Color(0, 0, 0, 1.0)

var days = 1
var hour = 8
var minute = 0

var currentTemp = 45.0
var maxTemp = 120.0
var minTemp = -10.0

const deltaTemp = 0.25

var timeOfDay = "day"

const day = "day"
const night = "night"
const dusk = "dusk"
const dawn = "dawn"

var _timer = null

func _ready():
	_timer = Timer.new()
	add_child(_timer)
		
	_timer.connect("timeout", self, "_on_Timer_timeout")
	_timer.set_wait_time(0.3)
	_timer.set_one_shot(false)
	_timer.start()
	
	self.connect("hero_temp_changed", self, "on_hero_temp_change")
	
	update_lighting(day)
	
func on_hero_temp_change(temp: float):
	$CanvasLayer/thermometer.on_hero_temp_change(temp)
	
	var blurAmount = 0
	var blurSpeed = 1
	
	if(temp >= 80 || temp <= 20):
		blurAmount = 1
	elif(temp >= 90):
		blurAmount = 2
		blurSpeed = 2
		
	$CanvasLayer/blur.get_material().set_shader_param("blur_amount", blurAmount)
	$CanvasLayer/blur.get_material().set_shader_param("blur_speed", blurSpeed)
	
func stop_effects():
	$CanvasLayer/blur.get_material().set_shader_param("blur_amount", 0)
	$CanvasLayer/blur.get_material().set_shader_param("blur_speed", 1)
	
	#todo show you died or something

func _on_Timer_timeout():
	minute += 1
	
	if minute >= 60:
		minute = 0
		hour += 1
		
	if hour >= 24:
		hour = 0
		days += 1
		$CanvasLayer/day.text = "Day %d" % days
		
	timeLabel.text = "%02d:%02d" % [hour, minute]
	
	if hour == 6 && minute == 0:
		update_lighting(dawn)
	elif hour == 6 && minute == 30:
		update_lighting(day)
	elif hour == 18 && minute == 0:
		update_lighting(dusk)
	elif hour == 18 && minute == 30:
		update_lighting(night)
		
	if (hour >= 6 && hour <= 14) && currentTemp < maxTemp:
		currentTemp += deltaTemp
	elif (hour <= 6 || hour == 18) && minute < 30 && currentTemp > minTemp:
		currentTemp -= deltaTemp * 2.3
	elif (hour <= 6 || hour >= 18) && currentTemp > minTemp:
		currentTemp -= deltaTemp
	
	hero.outsideTemp = currentTemp
	
	tempLabel.text = "%s°" % floor(currentTemp)

func update_lighting(newTimeOfDay):
	for item in get_tree().get_nodes_in_group("timeOfDay"):
		item.timeOfDay = newTimeOfDay
	
	var targetColor = Color(0, 0, 0, 1.0)
	var targetEnergy = 1
	var delay = 0.0

	if timeOfDay == night:
		delay = 0.3
		
	timeOfDay = newTimeOfDay

	if timeOfDay == night:
		targetColor = Color(0.1, 0.1, 0.3, 1.0)
	elif timeOfDay == dusk:
		targetColor = Color(0.3, 0.1, 0.5, 1.0)
	elif timeOfDay == dawn:
		targetColor = Color(0.98, 0.482, 0.384, 1.0)
	else:
		targetColor = Color(1.0, 1.0, 1.0, 1.0)
		timeOfDay = day
		targetEnergy = 0

	
	$ModulateTween.interpolate_property($CanvasModulate, "color", $CanvasModulate.color, targetColor, 5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, delay)
	$ModulateTween.start()

func handle_win():
	$sortedSprites/Hero.handle_death()
	$CanvasLayer/dead/Label.text = "You won!\nHit escape now."
	show_modal()
	
func handle_too_hot():
	$CanvasLayer/dead/Label.text = "You overheated :(\nHit escape now."
	show_modal()
	
func handle_too_cold():
	$CanvasLayer/dead/Label.text = "You caught the dead :(\nHit escape now."
	show_modal()
	
func show_modal():
	$ModulateTween.interpolate_property($CanvasLayer/dead, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$ModulateTween.start()
