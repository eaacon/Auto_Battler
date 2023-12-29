class_name Apprentice
extends Unit

@export var USkill: PackedScene

func _ability():
	In_Skill = true
	
	var ability_inst = USkill.instantiate()
	$FirePoint.add_child(ability_inst)
	ability_inst._setup(Vector3(1,0,0), Player_Unit)
	
	UCurrentMeter = 0
	In_Skill = false
