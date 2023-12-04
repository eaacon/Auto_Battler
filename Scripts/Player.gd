class_name Player
extends BoardManager

@export var Base_Money :int = 10

var Money: int:
	set(amt):
		Money = amt
		GM.Game_UI._set_money(Money)

func _setup():
	super._setup()
	Money = Base_Money

func _pay(v: int):
	Money += v

func _spend(v: int):
	if Money >= v:
		Money -= v
		return true
	else:
		return false
