class_name EnemyAI
extends BoardManager

@export var E_Teams: Array[Comp]
var Team_Index:= 1

var Hidden:= true

func _ready():
	super._ready()
	$'..'.setup.connect(_hide)
	$'..'.prep.connect(_round_prep)

func _setup():
	Team = E_Teams[0].duplicate()
	super._setup()

func _hide():
	if !Hidden:
		$Board/AnimationPlayer.play("Exit_Right")
		Hidden = true

func _round_prep():
	if Team_Index < E_Teams.size():
		Team = E_Teams[Team_Index].duplicate()
		Team_Index += 1
	if Hidden:
		$Board/AnimationPlayer.play("Enter_Right")
		Hidden = false
