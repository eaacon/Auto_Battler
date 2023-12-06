extends Area3D

func _process(_delta):
	if has_overlapping_areas():
		for a in get_overlapping_areas():
			a._boost()
