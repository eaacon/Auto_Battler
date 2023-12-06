class_name Unit
extends Node3D

#UI
signal S_Health
signal S_Meter

#Info
var UOwner: BoardManager
var UTile: Tile
var Acting:= false

@export var UStats: Stats
@export var UHitbox:Area3D
@export var UAttack: PackedScene
var Player_Unit:bool

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
@export var USkill: PackedScene

#In-Game
var QDmg: int

var Queue_Move:= false
var Queue_Advance := false

func _ready():
	UMaxHP = UStats.UHP
	UMaxMeter = UStats.UMeter
	UCurrentHP = UMaxHP
	UCurrentMeter = 0

func _setup(p:int, o:BoardManager):
	UOwner = o
	if p == 1:
		UHitbox.set_collision_layer_value(2, false)
		UHitbox.set_collision_layer_value(1, true)
		Player_Unit = true
	elif p == 2:
		rotate_y(PI)
		UHitbox.set_collision_layer_value(1, false)
		UHitbox.set_collision_layer_value(2, true)
		Player_Unit = false

func _start_turn():
	Acting = true

	if !_check_range():
		Queue_Advance = true
		Acting = false
		return
	else:
		if _can_attack():
			if(UCurrentMeter == UMaxMeter):
				#implement ability
				_ability()
				UCurrentMeter = 0
			else:
				_attack()
				UCurrentMeter += 1
		else:
			Queue_Move = true
			Acting = false

func _end_turn():	
	if Queue_Move:
		_move()
		Queue_Move = false
	elif Queue_Advance:
		_advance()
		Queue_Advance = false

	UCurrentHP -= QDmg
	QDmg = 0
	
	if UCurrentHP <= 0:
		_die()

func _check_range():
	var In_Range := false
	var B = UTile.Owner_Board
	for r in UStats.URange:
		var TBoard
		var Target_X = _get_target_x(r)

		var Valid_X = _get_valid_X(Target_X, B)
		
		if Target_X == Valid_X:
			TBoard = B
		else:
			TBoard = B.GM._get_opposing_board(B)
			Target_X= Valid_X
		
		var u_to_check = TBoard._get_col_units(Target_X-1)

		for u in u_to_check:
			if u.UOwner != UOwner:
				In_Range = true
				break

	return In_Range

func _can_attack():
	#plus for melee
	#raycast line/specific position for ranged
	#add loop if multiple
	var B = UTile.Owner_Board
	for r in UStats.URange:
		var TBoard
		var Target_X = _get_target_x(r)
		
		var Valid_X = _get_valid_X(Target_X, B)
		
		if Target_X == Valid_X:
			TBoard = B
		else:
			TBoard = B.GM._get_opposing_board(B)
			Target_X = Valid_X
		
		var Tar = TBoard._get_unit(Target_X-1, UTile.Coords.y -1)
		if Tar != null:
			if Tar.UOwner != UOwner:
				return true
	return false

func _get_target_x(r):
	var Target_X = UTile.Coords.x
	if Player_Unit:
		return Target_X + (r + 1)
	else:
		return Target_X - (r + 1)

func _attack():
	var attack_inst = UAttack.instantiate()
	$FirePoint.add_child(attack_inst)
	attack_inst._setup(UStats.UAttack + randi_range(-1, 1), UStats.URange, Vector3(1,0,0), Player_Unit)

func _ability():
	var ability_inst = USkill.instantiate()
	$FirePoint.add_child(ability_inst)
	ability_inst._setup(Vector3(1,0,0), Player_Unit)

func _move():
	var Move_Options = []
	Move_Options.append(Vector2i(UTile.Coords.x - 1, _get_valid_Y(UTile.Coords.y + 1, UTile.Owner_Board) - 1))
	Move_Options.append(Vector2i(UTile.Coords.x - 1, _get_valid_Y(UTile.Coords.y - 1, UTile.Owner_Board) - 1))
	var randDir = Move_Options[randi() % Move_Options.size()]
	UTile._move_unit(randDir)
	print(UStats.UName + " at " + str(UTile.name) + " moves to " + str(randDir.x+1) + "-"+ str(randDir.y+1))

func _advance():
	var B = UTile.Owner_Board
	var Move_Tile = UTile.Coords
	if B.GM._is_player(B.Owner):
		Move_Tile.x += 1
	else:
		Move_Tile.x -= 1

	var V_X = _get_valid_X(Move_Tile.x, B)
	if Move_Tile.x == V_X:
		UTile._move_unit(Move_Tile - Vector2i(1, 1))
	elif UStats.URange == 1:
		UTile._hop_unit(Vector2i(V_X, Move_Tile.y) - Vector2i(1, 1))
	else:
		_move()

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
	UOwner._kill(self)
	UTile._kill_unit()

func _queue_dmg(v: int):
	QDmg += v

func _damage(v: int):
	UCurrentHP -= v
	if UCurrentHP <= 0:
		visible = false
