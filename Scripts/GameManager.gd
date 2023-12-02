class_name GameManager
extends Node3D

enum Stage {START, SETUP, PREP, COMBAT, FINISH}

var Current_Stage: Stage

@onready var Player := $Player

@onready var Game_UI := $UI

@onready var GTimer = $GameTimer

@export var Setup_Time = 30
@export var Combat_Time = 60

func _ready():
	print(Stage.keys()[Current_Stage])
	Player._setup()
	_begin_game()

func _process(_delta):
	Game_UI._update_time(GTimer.time_left)

func _begin_game():
	GTimer.start()

func _on_game_timer_timeout():
	_next_stage()

func _next_stage():
	match Current_Stage:
		Stage.SETUP:
			_prep()
		Stage.PREP:
			_combat()
		Stage.COMBAT:
			_finish()
		Stage.FINISH:
			_setup()
		_:
			_setup()

	Game_UI._set_stage_label(Stage.keys()[Current_Stage])

func _setup():
	Current_Stage = Stage.SETUP
	
	Player._pay(5)
	Player.Board._set_interactable(true)
	
	GTimer.wait_time = Setup_Time
	GTimer.start()
	print("Setup Stage")

func _prep():
	Current_Stage = Stage.PREP
	Player.Board._set_interactable(false)
	print("Prep Stage")
	_next_stage()

func _combat():
	Current_Stage = Stage.COMBAT
	GTimer.wait_time = Combat_Time
	GTimer.start()
	print("Combat Stage")

func _finish():
	Current_Stage = Stage.FINISH
	print("Finished Stage")
	_next_stage()
