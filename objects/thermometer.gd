extends Sprite

func on_hero_temp_change(newTemp: float):
	var temp = 20 + (newTemp * 0.8) 
	temp = 100 - temp
	
	$"thermometer-filled".get_material().set_shader_param("cutoff", temp / 100.0)
