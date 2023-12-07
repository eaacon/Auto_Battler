class_name Tile
extends Node3D

var Owner_Board: Board

var Coords: Vector2i
var Unit_On_Tile:
	set(new_unit):
		Unit_On_Tile = new_unit

func _setup(x, y, board):
	Coords = Vector2(x, y)
	Owner_Board = board

func _create_unit(u:Unit, p:int):
	Owner_Board.Owner.Units_Alive.append(u)
	_place_unit(u)
	Owner_Board.Owner._create_unit_ui(u)
	u._setup(p, Owner_Board.Owner.GM.Players[p-1])

func _place_unit(u:Unit):
	add_child(u)
	
	u.UTile = self
	Unit_On_Tile = u

func _move_unit(p: Vector2i):
	#set unit on tile variable
	if Owner_Board.Grid[p.x][p.y].Unit_On_Tile == null:
		if Unit_On_Tile.get_parent() == self:
			remove_child(Unit_On_Tile)
		Owner_Board.Grid[p.x][p.y]._place_unit(Unit_On_Tile)
	else:
		return null
	Unit_On_Tile = null

func _hop_unit(p: Vector2i):
	var opp_board = Owner_Board.GM._get_opposing_board(Owner_Board)
	if opp_board.Grid[p.x][p.y].Unit_On_Tile == null:
		remove_child(Unit_On_Tile)
		opp_board.Grid[p.x][p.y]._place_unit(Unit_On_Tile)
	else:
		return null
	Unit_On_Tile = null

func _kill_unit():
	Owner_Board.GM._out_of_play(Unit_On_Tile)
	_remove_unit()

func _remove_unit():
	Unit_On_Tile.queue_free()
	Unit_On_Tile = null
