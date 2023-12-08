class_name GameManager
extends Node3D

static var Held:bool = false
static var Can_Interact:bool = false

#Game Settings
enum Stage {START, SETUP, PREP, COMBAT, FINISH}
signal win
signal lose
signal start
signal setup
signal prep

var Current_Stage: Stage

@onready var Cam = $Camera3D

@onready var Players: Array[BoardManager]

@onready var Game_UI := $UI

@onready var GTimer = $GameTimer

@export var Setup_Time := 30
#@export var Combat_Time = 60
@export var Round_Delay := 1

@export var Base_Player_Damage:int = 3
var Unit_UI = preload("res://Scenes/UI/Unit_Info_Control.tscn")

#Game Info
var Units_In_Play = []
var Round_Num := 0
var Turn_Active := false
signal Next_Turn
signal End_Combat
var Kill_Queue = []

func _ready():
	print("-Start Game")
	Players.append($Player)
	Players.append($EnemyAI)
	
	for p in Players:
		p.GM = self
		p._setup()

	_begin_game()

func _process(_delta):
	Game_UI._update_time(GTimer.time_left)
	
	#combat turn acting
	if(Turn_Active):
		for u in Units_In_Play:
			if(u.Acting):
				return
	
	Next_Turn.emit()
	Turn_Active = false

func _begin_game():
	start.emit()
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
	setup.emit()
	Current_Stage = Stage.SETUP
	
	Units_In_Play.clear()
	
	for p in Players:
		p._set_board()
	
	Players[0]._pay(5)
	
	await $Shop/AnimationPlayer.animation_finished
	Can_Interact = true
	GTimer.wait_time = Setup_Time
	GTimer.start()
	print("-Setup Stage")

func _prep():
	Can_Interact = false
	$Shop._hide()
	await $Shop/AnimationPlayer.animation_finished
	prep.emit()
	Current_Stage = Stage.PREP
	
	#matchmake opponent
	#get all units in battle
	for b in Players:
		Units_In_Play.append_array(b.board._get_units())

	print("-Prep Stage")
	await $EnemyAI/Board/AnimationPlayer.animation_finished
	_next_stage()

func _combat():
	Current_Stage = Stage.COMBAT
	print("-Combat Stage")
	_combat_round()

func _combat_round():
	Round_Num += 1
	print("-Round "+str(Round_Num))
	if(Round_Num > 30):
		print("! too many rounds")
		Round_Num = 0
		_next_stage()
		return

	Game_UI._set_stage_label("ROUND "+str(Round_Num))

	Turn_Active = true

	for u in Units_In_Play:
		if u != null:
			u._start_turn()
	
	await Next_Turn
	
	for u in Units_In_Play:
		if u != null:
			u._end_turn()
	
	for k in Kill_Queue:
		Units_In_Play.erase(k)

	await get_tree().create_timer(Round_Delay).timeout
	
	if _check_combat_win():
		print("-Combat End")
		Round_Num = 0
		_next_stage()
	else:
		_combat_round()

func _out_of_play(u):
	Kill_Queue.append(u)

func _check_combat_win():
	var p1 = Players[0].Units_Alive.size()
	var p2 = Players[1].Units_Alive.size()
	
	if p1 <= 0 && p2 <= 0:
		Players[0]._take_damage(Base_Player_Damage)
		Players[1]._take_damage(Base_Player_Damage)
	elif p2 <= 0:
		Players[0]._pay(1)
		Players[1]._take_damage(Base_Player_Damage + p1)
	elif p1 <= 0:
		Players[0]._take_damage(Base_Player_Damage + p2)
	else:
		return false
	return true

func _finish():
	Current_Stage = Stage.FINISH
	
	if Players[1].Current_Health <= 0:
		print("You Win!")
		for p in Players:
			p.board._clear()
		win.emit()
		return
	elif Players[0].Current_Health <= 0:
		print("Enemy Wins...")
		lose.emit()
		return

	print("-Finished Stage")
	_next_stage()

func _get_opposing_board(b):
	if Players.size() < 2:
		print("< 2 Boards")
		return null

	if Players[0].board == b:
		return Players[1].board
	elif Players[1].board == b:
		return Players[0].board

func _is_player(p: BoardManager):
	if p == Players[0]:
		return true
	else:
		return false
