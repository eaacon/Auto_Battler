extends Node

@onready var GM
@onready var board := $Board

func _setup():
	board.GM = GM
	board._build_grid(self)

