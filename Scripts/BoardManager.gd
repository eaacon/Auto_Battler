class_name BoardManager
extends Node

@onready var GM
@onready var board := $Board

var Team: Comp

func _setup():
	board.GM = GM
	board._build_grid(self)

func _set_board():
	if Team == null:
		return;

	board._clear()
	
	for u in Team.Comp_Units:
		#make place unit depend on comp unit scene
		board.Grid[u.location.x-1][u.location.y-1]._place_unit(u.unit.instantiate())
