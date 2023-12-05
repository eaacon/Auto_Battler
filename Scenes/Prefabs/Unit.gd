class_name Unit
extends Node3D

#UI
signal S_Health
signal S_Meter

#Info
var UOwner: BoardManager
var Acting:= false
@export var UStats: Stats
var UTile: Tile

#Gameplay
@onready var UMaxHP:int
var UCurrentHP:
	set(hp):
		UCurrentHP = hp
		S_Health.emit()

@onready var UMaxMeter: int
var UCurrentMeter:
	set(m):
		UCurrentMeter = m
		S_Meter.emit()

#Skill
@export var SDmg: int = 5
@export var SCost:int = 3
@export var SRange:int = 3

#In-Game
var QDmg: int

var Queue_Move:= false
var Queue_Move_Forward := false

func _ready():
	UMaxHP = UStats.UHP
	UMaxMeter = UStats.UMeter
	UCurrentHP = UMaxHP
	UCurrentMeter = 0

func _start_turn():
	#check to see if anyone to hit, otherwise move down
	#if target is valid, 
	Acting = true
	
	#_check_range()
	if !_check_range():
		Queue_Move_Forward = true
		Acting = false
		return
	#check line of sight
	var t = _calc_target()
	if t != null:
		if(UCurrentMeter == UMaxMeter):
			#implement ability
			_attack(t)
			UCurrentMeter += 1
		else:
			_attack(t)
			UCurrentMeter += 1
	else:
		Queue_Move = true
		Acting = false

func _end_turn():	
	if Queue_Move:
		_move()
		Queue_Move = false
	elif Queue_Move_Forward:
		_move_f()
		Queue_Move_Forward = false

	UCurrentHP -= QDmg
	QDmg = 0
	
	if UCurrentHP <= 0:
		_die()

func _calc_target():
	var Aim_X = UTile.Coords.x
	var B = UTile.Owner_Board

	if B._is_player():
		#attack right
		Aim_X += UStats.URange
	else:
		#attack left
		Aim_X -= UStats.URange
	
	#T is target
	var TBoard = B.GM._get_opposing_board(B)
	
	if(TBoard == null):
		print("Failed to get target board")
		return;
	
	var Valid_X = _get_valid_X(Aim_X, B)

	if Aim_X == Valid_X:
		TBoard = B
	else:
		Aim_X = Valid_X

	var TUnit = TBoard.Grid[Aim_X-1][UTile.Coords.y-1].Unit_On_Tile
	
	#debug
	#var Aim_Coords = Vector2(Aim_X, UTile.Coords.y)
	#if TUnit != null:
		#print(UStats.UName + " at " + str(UTile.name) + " aims at " + TUnit.UStats.UName + " at " + str(Aim_Coords))
	if TUnit.UOwner != UOwner:
		return TUnit

func _check_range():
	var In_Range := false
	var B = UTile.Owner_Board
	for r in UStats.URange:
		var TBoard
		for y in B.GridH:
			var Target_X = UTile.Coords.x + r + 1
			var Valid_X = _get_valid_X(Target_X, B)
			
			if Target_X == Valid_X:
				TBoard = B
			else:
				TBoard = B.GM._get_opposing_board(B)
				Target_X= Valid_X
			
			var TUnit = TBoard.Grid[Target_X-1][UTile.Coords.y-1].Unit_On_Tile
			
			if TUnit == null:
				continue

			if TUnit.UOwner != UOwner:
				In_Range = true
				break
	#retun in range
	return false

func _check_line_of_sight():
	pass
func _attack(target):
	print(str(self.name) + " deals " + str(UStats.UAttack) + " to "\
		+ str(target.name) + " at " + str(target.UTile.name))
	
	target._queue_dmg(UStats.UAttack)
	Acting = false
	pass

func _move():
	var Move_Options = []
	Move_Options.append(Vector2i(UTile.Coords.x - 1, _get_valid_Y(UTile.Coords.y + 1, UTile.Owner_Board) - 1))
	Move_Options.append(Vector2i(UTile.Coords.x - 1, _get_valid_Y(UTile.Coords.y - 1, UTile.Owner_Board) - 1))
	var randDir = Move_Options[randi() % Move_Options.size()]
	UTile._move_unit(randDir)
	print(UStats.UName + " at " + str(UTile.name) + " moves to " + str(randDir.x+1) + "-"+ str(randDir.y+1))

func _move_f():
	var B = UTile.Owner_Board
	var Move_Tile = UTile.Coords
	if B._is_player():
		Move_Tile.x += 1
	else:
		Move_Tile.x -= 1

	var V_X = _get_valid_X(Move_Tile.x, B)
	if Move_Tile.x != V_X:
		UTile._hop_unit(Vector2i(V_X, Move_Tile.y) - Vector2i(1, 1))
	else:
		UTile._move_unit(Move_Tile - Vector2i(1, 1))
	print(UStats.UName + " at " + str(UTile.name) + " moves to " + str(Move_Tile.x+1) + "-"+ str(Move_Tile.y+1))
	
func _get_valid_X(x, _b):
	if x > _b.GridW * 2:
		return _b.GridW
	elif x > _b.GridW:
		return x - _b.GridW
	elif x < -(_b.GridW * 2):
		return 1
	elif x < 1:
		return x + _b.GridW
	else:
		return x

func _get_valid_Y(y, _b):
	if y > _b.GridH * 2:
		return _b.GridH
	elif y > _b.GridH:
		return y - _b.GridH
	elif y < -(_b.GridH * 2):
		return 1
	elif y < 1:
		return y + _b.GridH
	else:
		return y

func _die():
	print(self.name + " died")
	UTile._kill_unit()

func _queue_dmg(v: int):
	QDmg += v
