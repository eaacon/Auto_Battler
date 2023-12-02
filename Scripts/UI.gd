class_name UI
extends CanvasLayer

@onready var stage = $Control/MarginContainer/VBoxContainer/Stage/MarginContainer/Label

@onready var T_Panel = $Control/MarginContainer/VBoxContainer/TimerPanel
@onready var T = T_Panel.get_child(0)
@onready var M = $Control/MarginContainer/Money_Panel/Money

func _ready():
	stage.text = "START!"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _set_stage_label(text):
	stage.text = str(text)

func _set_money(num):
	M.text = "$ %d" % num

func _update_time(v):
	if v <= 0.1:
		if T_Panel.visible:
			T_Panel.visible = false
		else:
			pass
	else:
		if not T_Panel.visible:
			T_Panel.visible = true
		T.text = str(ceili(v))
