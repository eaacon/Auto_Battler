class_name Tile
extends Node3D

var Owner_Board: Board

var Coords: Vector2i
var Unit_On_Tile:
	set(new_unit):
		Unit_On_Tile = new_unit

@onready var Default_Mat = preload("res://Art/Materials/Default_Tile_Material.tres")
@onready var Selected_Mat = preload("res://Art/Materials/Default_Tile_Selected_Material.tres")

func _setup(x, y, board):
	Coords = Vector2(x, y)
	Owner_Board = board

func _set_pickable(b):
	$MeshInstance3D/StaticBody3D.input_ray_pickable = b

func _on_static_body_3d_mouse_entered():
	if Owner_Board._is_player():
		$MeshInstance3D.material_override = Selected_Mat

func _on_static_body_3d_mouse_exited():
	if Owner_Board._is_player():
		$MeshInstance3D.material_override = Default_Mat

func _on_static_body_3d_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed == true:
			if Owner_Board._is_player():
				_buy_unit()

func _buy_unit():
	var inst = load("res://Scenes/Prefabs/Unit.tscn").instantiate()
	if Owner_Board.get_parent()._spend(inst.UStats.UCost):
		_place_unit(inst)

func _place_unit(u:Unit):
	if Unit_On_Tile == null:
		add_child(u)
		u.UTile = self
		Unit_On_Tile = u
		print("Placed " + u.name + " on " + self.name)

func _move_unit(p: Vector2i):
	Owner_Board.Grid[p.x][p.y].Unit_On_Tile = Unit_On_Tile
	Unit_On_Tile = null

func _kill_unit():
	Owner_Board.GM._out_of_play(Unit_On_Tile)
	Unit_On_Tile.queue_free()
	Unit_On_Tile = null
