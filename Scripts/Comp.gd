class_name Comp
extends Resource

@export var Comp_Units: Array[CompUnit]

func _add_unit(u:PackedScene, l:Vector2i):
	var U_Data = CompUnit.new()
	U_Data._setup(u, l)
	Comp_Units.append(U_Data)

func _move_unit(from, to):
	for u in Comp_Units:
		if u.location == from:
			u.location = to
