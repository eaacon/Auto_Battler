class_name Tile
extends Node3D

var Owner_Board: Board

var Coords: Vector2
var Unit_On_Tile

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
			_place_unit()

func _place_unit():
	if Unit_On_Tile == null and Owner_Board._is_player():
		var inst = load("res://Scenes/Prefabs/Unit.tscn").instantiate()
		inst.UTile = self
		if(Owner_Board.get_parent()._spend(inst.UStats.UCost)):
			add_child(inst)
			Unit_On_Tile = inst
			print("Placed " + inst.name + " on " + self.name)

func _move_unit(p: Vector2):
	Owner_Board.Grid[p.x].insert(p.y, Unit_On_Tile)
	Unit_On_Tile = null
	Owner_Board.Grid[Coords.x-1].remove_at(Coords.y-1)

func _kill_unit():
	Owner_Board.Grid[Coords.x-1].remove_at(Coords.y-1)
	Unit_On_Tile.queue_free()
