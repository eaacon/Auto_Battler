class_name Board
extends Node3D

@onready var GM = $".."

@export var PlayerBoard:= false

@export var GridW:= 4
@export var GridH:= 4

@export var Tile = load("res://Scenes/Prefabs/Tile.tscn")

@export var offset = Vector2(0.5, 0.5)

var Tile_List = []

func _ready():
	pass

func _process(_delta):
	pass

func _build_grid():
	for i in GridW:
		for j in GridH:
			_make_tile(i, j)

	if PlayerBoard:
		translate(Vector3(-GridW, 0 ,0))

func _make_tile(x, y):
	var inst = Tile.instantiate()
	Tile_List = get_children()
	add_child(inst)
	inst.translate(Vector3(x + offset.x, 0, y + offset.y))
	
	if PlayerBoard:
		inst.Player = get_parent()

func _set_interactable(b):
	for t in get_children():
		t._set_pickable(b)
