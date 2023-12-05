class_name Unit
extends Node3D

#UI
signal S_Health
signal S_Meter

#Info
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
		_move()

func _end_turn():	
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

	return TUnit

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
	Acting = false

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
