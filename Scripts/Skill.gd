class_name Skill
extends Area3D

@export var SDmg: int = 5
@export var SRange:int = 3
@export var Speed: float = 2
var Dir: Vector3

var tween
func _setup(Direction:Vector3, Is_Player):
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
			
			a.get_parent()._damage(SDmg + randi_range(-1, 1))
			_destroy()

func _fire():
	tween = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "position", SRange*Dir, SRange/Speed).set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(_destroy)

func _boost():
	if tween:
		tween.kill()
	tween = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "position", (SRange+1)*Dir, ((SRange+1)*Dir - position).length()/Speed)
	tween.tween_callback(_destroy)

func _destroy():
	get_parent().get_parent().Acting = false
	if tween:
		tween.kill()
	queue_free()
