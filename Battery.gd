extends Pickup

class_name Battery

export var charge = 0

func can_drop():
	# TODO check drop spot for collsion and return false if not possible.
	return true

func _physics_process(delta):
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
