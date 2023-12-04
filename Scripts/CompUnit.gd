class_name CompUnit
extends Resource

@export var unit: PackedScene
@export var location: Vector2i

func _setup(u, loc):
	unit = u
	location = loc
