class_name Board
extends Node3D

@onready var GM

var Owner: BoardManager

@export var GridW:= 4
@export var GridH:= 4

@export var BTile = load("res://Scenes/Prefabs/Tile.tscn")

@export var offset = Vector2(0.5, 0.5)

@onready var Grid: Array[Array]

func _build_grid(o):
	Owner = o
	for i in GridH:
		var New_Column = []
		for j in GridW:
			New_Column.append(_make_tile(i, j))
		Grid.append(New_Column)

	if GM._is_player(Owner):
		translate(Vector3(-GridW, 0 ,0))

func _make_tile(x, y):
	var inst = BTile.instantiate()
	inst._setup(x+1, y+1, self)
	inst.name = Owner.name.left(1) + str(x+1) + "-" + str(y+1)
	add_child(inst)
	
	inst.translate(Vector3(x + offset.x, 0, -(y + offset.y)))
	
	return inst

func _set_interactable(b):
	for t in get_children():
		if t == Tile:
			t._set_pickable(b)

func _clear():
	for x in Grid.size():
		for y in Grid[x].size():
			var t = Grid[x][y]
			if t.Unit_On_Tile != null:
				t._remove_unit()

func _get_units():
	var Unit_List = []
	for x in Grid.size():
		for y in Grid[x].size():
			var u = Grid[x][y].Unit_On_Tile
			if u != null:
				Unit_List.append(u)
	return Unit_List

func _get_unit(x, y):
	return Grid[x][y].Unit_On_Tile

func _get_col_units(colX):
	var units_in_col = []
	for y in Grid[colX].size():
		if Grid[colX][y].Unit_On_Tile != null:
			units_in_col.append(Grid[colX][y].Unit_On_Tile)
	return units_in_col

func _units_alive():
	var alive:= 0
	for x in Grid.size():
		for y in Grid[x].size():
			var u = Grid[x][y].Unit_On_Tile
			if u != null:
				alive += 1
	return alive
