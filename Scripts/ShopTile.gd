class_name ShopTile
extends Node3D

@export var S: Shop

var Unit_Scene:PackedScene

var Shop_Unit:
	set(new_unit):
		Shop_Unit = new_unit

func _set_pickable(b):
	$MeshInstance3D/StaticBody3D.input_ray_pickable = b

func _set_unit(US:PackedScene, u:Unit):
	_place_unit(u)
	Unit_Scene = US
	u._setup(1, S.P)

func _buy_unit(u, target):
	if S.P._spend(u.UStats.UCost):
		S.P.Units_Alive.append(u)
		S.P._create_unit_ui(u)
		S.P.Team._add_unit(Unit_Scene, target)
		_move_unit(target- Vector2i(1,1))
		return true
	return false

func _move_unit(p: Vector2i):
	var Grid = S.P.board.Grid
	if Grid[p.x][p.y].Unit_On_Tile == null:
		Grid[p.x][p.y]._place_unit(Shop_Unit)
	else:
		return null
	Shop_Unit = null
	Unit_Scene = null

func _place_unit(u:Unit):
	add_child(u)
	u.UTile = self
	Shop_Unit = u

func _remove_unit():
	if Shop_Unit != null:
		Shop_Unit.queue_free()
		Shop_Unit = null
