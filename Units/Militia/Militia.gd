class_name Militia
extends Unit

var Blocking:= false

func _ability():
	In_Skill = true
	
	Blocking = true
	$BlockFX.show()
	_turn()

func _damage(v: int):
	var Mod_Dmg = v

	if Blocking:
		Mod_Dmg = int(v * 0.75)
		Blocking = false
		UCurrentMeter = 0
		In_Skill = false
		$BlockFX.hide()
	
	super._damage(Mod_Dmg)
