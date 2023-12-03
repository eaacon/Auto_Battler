class_name Unit
extends Node3D

#Info
var Acting:= false
@export var UStats: Stats
var UTile: Tile

#Gameplay
@onready var UMaxHP:int
var UCurrentHP:int

@onready var UMaxMeter: int
var UCurrentMeter: int

#Skill
@export var SDmg: int = 5
@export var SCost:int = 3
@export var SRange:int = 3

#In-Game
var QDmg: int

func _ready():
	UMaxHP = UStats.UHP
	UMaxMeter = UStats.UMeter
	UCurrentHP = UMaxHP
	UCurrentMeter = 0

func _start_turn():
	#check to see if anyone to hit, otherwise move down
	#if target is valid, 
	Acting = true
	
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
		Acting = false

func _calc_target():
	var Aim_X = UTile.Coords.x
	var B = UTile.Owner_Board
	#is player?
	if B._is_player():
		#attack right
		Aim_X +=UStats.URange
	else:
		#attack left
		Aim_X -= UStats.URange
	
	#T is target
	var TBoard = B.GM._get_opposing_board(B)
	
	if(TBoard == null):
		print("Failed to get target board")
		return;

	if Aim_X >= B.GridW * 2:
		Aim_X = B.GridW-1
	elif Aim_X >= B.GridW:
		Aim_X -= B.GridW
	elif Aim_X <= -(B.GridW * 2):
		Aim_X = 0
	elif Aim_X <= 0:
		Aim_X += B.GridW
	else:
		TBoard = B

	var TUnit = TBoard.Grid[Aim_X][UTile.Coords.y-1].Unit_On_Tile
	
	var Aim_Coords = Vector2(Aim_X, UTile.Coords.y)
	if TUnit != null:
		print(UStats.UName + " at " + str(UTile.name) + " aims at " + TUnit.UStats.UName + " at " + str(Aim_Coords))
	else:
		print(UStats.UName + " at " + str(UTile.name) + " aims at empty" + str(Aim_Coords))

	return TUnit

func _attack(target):
	target._queue_dmg(UStats.UDmg)
	Acting = false
	pass

func _end_turn():
	UCurrentHP -= QDmg
	if UCurrentHP <= 0:
		_die()
	pass

func _die():
	UTile._kill_unit()

func _queue_dmg(v: int):
	QDmg += v
