class_name Unit
extends Node3D

#UI
signal S_Health
signal S_Meter

#Info
var UOwner: BoardManager
var UTile
var Fighting:= false

#Drag And Drop
var Picked_Up = false
@export var Tile_Detect: RayCast3D

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

var UCurrentAS

#Skill
var In_Skill:= false

func _ready():
	UMaxHP = UStats.UHP
	UMaxMeter = UStats.UMeter
	UCurrentHP = UMaxHP
	UCurrentMeter = 0
	UCurrentAS = UStats.USpeed

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

func _connect_GM():
	UOwner.GM.combat.connect(_fighting)
	UOwner.GM.finish.connect(_fighting)

func _ability():
	_attack()
	$Timer.wait_time = 1/UCurrentAS
	$Timer.start()

func _fighting():
	Fighting = !Fighting
	_turn()

func _process(_delta):
	if UCurrentHP <= 0:
		_die()

	_pickup_logic()

func _turn():
	if !_check_range():
		_advance()
	else:
		if _can_attack():
			if UCurrentMeter == UMaxMeter:
				if !In_Skill:
					_ability()
				else:
					return
			else:
				_attack()
				UCurrentMeter += 1
		else:
			_move()

	$Timer.wait_time = 1/UCurrentAS
	$Timer.start()

func _on_timer_timeout():
	if Fighting:
		_turn()

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

func _damage(v: int):
	UCurrentHP -= v

#Drag and Drop
func _pickup_logic():
	if Picked_Up:
		if !GameManager.Can_Interact:
			reparent(UTile)
			_drop()

		if _screen_to_world().has("position"):
			position = _screen_to_world()["position"]
		else:
			reparent(UTile)
			_drop()
		
		if Input.is_action_just_released("click"):
			if !Tile_Detect.is_colliding():
				reparent(UTile)
			else:
				var Under = Tile_Detect.get_collider().get_parent().get_parent()
				if Under.get_script() == Tile:
					_mouse_release_on_tile(Under)
				else:
					reparent(UTile)
			_drop()
	elif position != Vector3.ZERO:
		position = Vector3.ZERO

func _on_area_3d_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton && GameManager.Can_Interact:
		if event.pressed == true && !GameManager.Held:
			reparent(get_tree().root)
			Picked_Up = true
			GameManager.Held = true

func _mouse_release_on_tile(Under):
	if Under.Unit_On_Tile == null:
		if UTile.get_script() == ShopTile:
			#buy
			get_parent().remove_child(self)
			if !UTile._buy_unit(self, Under.Coords):
				UTile.add_child(self)
		elif UTile.get_script() == Tile:
			#move
			get_parent().remove_child(self)
			UOwner.Team._move_unit(UTile.Coords, Under.Coords)
			UTile._move_unit(Under.Coords - Vector2i(1, 1))
	else:
		print("no room")
		reparent(UTile)

func _drop():
	Picked_Up = false
	GameManager.Held = false
	position = Vector3.ZERO

func _screen_to_world():
	var physics_space = get_world_3d().direct_space_state
	var MPos = get_viewport().get_mouse_position()
	var cam = get_tree().root.get_camera_3d()

	var ray_start = cam.project_ray_origin(MPos)
	var ray_end = ray_start + cam.project_ray_normal(MPos) * 1000
	var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end)
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.collision_mask = 16
	var intersects = physics_space.intersect_ray(query)

	return intersects
