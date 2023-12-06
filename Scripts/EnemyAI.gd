class_name EnemyAI
extends BoardManager

@export var Team_Preset: Comp

var Hidden:= true

func _ready():
	super._ready()
	$"..".setup.connect(_hide)
	$"..".prep.connect(_show)

func _setup():
	if Team_Preset != null:
		Team = Team_Preset.duplicate()
	super._setup()

func _hide():
	if !Hidden:
		$Board/AnimationPlayer.play("Exit_Right")
		Hidden = true

func _show():
	if Hidden:
		$Board/AnimationPlayer.play("Enter_Right")
		Hidden = false
