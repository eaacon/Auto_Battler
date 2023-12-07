class_name Shop
extends Node3D

@export var GM:GameManager
@onready var P: BoardManager

#Slots
@export var Slots: Array[ShopTile]

@export var For_Sale: Array[PackedScene]

func _ready():
	for s in Slots:
		s.S = self
	GM.start.connect(_start)
	GM.setup.connect(_setup)

func _start():
	P = GM.Players[0]

func _setup():
	$AnimationPlayer.play("Enter_Top")
	_clear()
	_stock()

func _hide():
	$AnimationPlayer.play("Exit_Bottom")

func _set_interactable(b):
	for t in Slots:
		t._set_pickable(b)

func _stock():
	for s in Slots:
		var Randu = randi_range(0, For_Sale.size()-1)
		var u = For_Sale[Randu].instantiate()
		s._set_unit(For_Sale[Randu], u)

func _reroll():
	if P._spend(2):
		_clear()
		_stock()

func _clear():
	for i in Slots.size():
		var t = Slots[i]
		t._remove_unit()
