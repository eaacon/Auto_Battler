class_name UnitInfoScript
extends Control

var U: Unit
var C: Camera3D
@export var HP_bar: ProgressBar
@export var Meter_bar: ProgressBar

func _process(_delta):
	if U != null:
		var UPos = C.unproject_position(U.global_position)
		if position != UPos:
			position = C.unproject_position(U.global_position)
	else:
		queue_free()

func _setup(u:Unit, c:Camera3D):
	U= u
	U.S_Health.connect(_update_HP)
	U.S_Meter.connect(_update_Meter)
	C = c

func _update_HP():
	if U.UMaxHP > 0:
		HP_bar.value = float(U.UCurrentHP)/U.UMaxHP

func _update_Meter():
	if U.UMaxMeter > 0:
		Meter_bar.value = float(U.UCurrentMeter)/U.UMaxMeter
