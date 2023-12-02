extends Node

@onready var GM = $".."
@onready var Board = $Board

var Base_Money :int = 10

var Money: int:
	set(amt):
		Money = amt
		GM.Game_UI._set_money(Money)

func _setup():
	Money = Base_Money
	Board._build_grid()

func _pay(v: int):
	Money += v

func _spend(v: int):
	if Money >= v:
		Money -= v
		return true
	else:
		return false
