extends Node

@onready var Board := $Board

# Called when the node enters the scene tree for the first time.
func _ready():
	Board._build_grid()
