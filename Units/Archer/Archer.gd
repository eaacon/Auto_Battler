class_name Archer
extends Unit

var Old_AS
@export var AS_Buff_Percent:= 200
@export var AS_Buff_Duration:float = 2

func _ability():
	In_Skill = true
	
	Old_AS = UCurrentAS
	UCurrentAS = Old_AS * AS_Buff_Percent/100
	
	$SkillDuration.wait_time = AS_Buff_Duration
	$SkillDuration.start()
	
	_part()

func _part():
	if !In_Skill:
		return
	
	_attack()
	
	$AbilityAttackTimer.wait_time = 1/UCurrentAS
	$AbilityAttackTimer.start()
	await $AbilityAttackTimer.timeout
	
	_part()

func _on_skill_duration_timeout():
	UCurrentAS = Old_AS
	UCurrentMeter = 0
	In_Skill = false
	_turn()
