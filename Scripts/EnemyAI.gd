class_name EnemyAI
extends BoardManager

@export var Team_Preset: Comp

func _setup():
	if Team_Preset != null:
		Team = Team_Preset.duplicate()
	super._setup()
