extends Node

@onready var GM
@onready var board = $Board

@export var Base_Money :int = 10

var Money: int:
	set(amt):
		Money = amt
		GM.Game_UI._set_money(Money)

func _setup():
	board.GM = GM
	Money = Base_Money
	board._build_grid(self)

func _pay(v: int):
	Money += v

func _spend(v: int):
	if Money >= v:
		Money -= v
		return true
	else:
		return false
