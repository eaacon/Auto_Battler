class_name Projectile
extends Area3D

var Dmg: int
var Dist
var Dir: Vector3
@export var Speed: float = 2

var tween

func _setup(Damage:int, Distance, Direction:Vector3, Is_Player):
	Dmg = Damage
	Dist = Distance
	Dir = Direction
	
	if Is_Player:
		set_collision_mask_value(1, false)
		set_collision_mask_value(2, true)
	else:
		set_collision_mask_value(1, true)
		set_collision_mask_value(2, false)
	
	_fire()

func _process(_delta):
	if has_overlapping_areas():
		for a in get_overlapping_areas():
			
			a.get_parent()._damage(Dmg)
			_destroy()

func _fire():
	tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "position", Dist*Dir, Dist/Speed).set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(_destroy)

func _boost():
	if tween:
		tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "position", (Dist+1)*Dir, ((Dist+1)*Dir - position).length()/Speed)
	tween.tween_callback(_destroy)

func _destroy():
	if tween:
		tween.kill()
	queue_free()
