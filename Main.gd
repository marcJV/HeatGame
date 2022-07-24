extends Node2D

func _physics_process(delta):
	if(Input.is_action_pressed("quit")):
		get_tree().quit()

func _on_Button_button_up():
	Transit.change_scene("res://Game.tscn")
	

func _on_Button2_button_up():
	$Tween.interpolate_property(self, "position", position, Vector2(0, 232), 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()


func _on_Button3_button_up():
	$Tween.interpolate_property(self, "position", position, Vector2.ZERO, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()


func _on_Button4_button_up():
	$Tween.interpolate_property(self, "position", position, Vector2(0, -190), 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
