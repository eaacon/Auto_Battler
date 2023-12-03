class_name Board
extends Node3D

@onready var GM

var Owner: Node

@export var GridW:= 4
@export var GridH:= 4

@export var BTile = load("res://Scenes/Prefabs/Tile.tscn")

@export var offset = Vector2(0.5, 0.5)

@onready var Grid: Array[Array]

func _build_grid(o):
	Owner = o
	for i in GridW:
		var New_Row = []
		for j in GridH:
			#j is x, i is y
			New_Row.append(_make_tile(j, i))
		Grid.append(New_Row)

	if _is_player():
		translate(Vector3(-GridW, 0 ,0))

func _make_tile(x, y):
	var inst = BTile.instantiate()
	inst._setup(x+1, y+1, self)
	inst.name = "T" + str(x+1) + "-" + str(y+1)
	add_child(inst)
	
	inst.translate(Vector3(x + offset.x, 0, -(y + offset.y)))
	
	return inst

func _set_interactable(b):
	for t in get_children():
		t._set_pickable(b)

func _get_units():
	var Unit_List = []
	for x in Grid.size():
		for y in Grid[x].size():
			var u = Grid[x][y].Unit_On_Tile
			if u != null:
				Unit_List.append(u)
	return Unit_List

func _units_alive():
	var alive:= 0
	for x in Grid.size():
		for y in Grid[x].size():
			var u = Grid[x][y].Unit_On_Tile
			if u != null:
				alive += 1
	return alive

func _is_player():
	if GM == null:
		print("No Game Manager")
		return
	return Owner == GM.Players[0]