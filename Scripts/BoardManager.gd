class_name BoardManager
extends Node

@export var Health_Label: Label3D
@export var Health:int = 30
var Current_Health:
	set(Player_HP):
		Current_Health = Player_HP
		if Health_Label != null:
			Health_Label.text = str(Current_Health) + "HP"

@onready var GM
@onready var board := $Board

var Team: Comp

var Units_Alive = []

func _ready():
	Current_Health = Health

func _setup():
	board.GM = GM
	board._build_grid(self)

func _set_board():
	if Team == null:
		return;
	
	Units_Alive.clear()
	board._clear()
	
	for u in Team.Comp_Units:
		#make place unit depend on comp unit scene
		var t = board.Grid[u.location.x-1][u.location.y-1]
		var i = u.unit.instantiate()
		if GM._is_player(self):
			t._create_unit(i, 1)
		else:
			t._create_unit(i, 2)

func _take_damage(d:int):
	Current_Health -= d

func _create_unit_ui(u:Unit):
	var UUI = GM.Unit_UI.instantiate()
	GM.Game_UI.add_child(UUI)
	UUI._setup(u, GM.Cam)

func _kill(u:Unit):
	Units_Alive.erase(u)
