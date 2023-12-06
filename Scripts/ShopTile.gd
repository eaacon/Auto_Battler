class_name ShopTile
extends Node3D

@export var S: Shop

var Shop_Unit:
	set(new_unit):
		Shop_Unit = new_unit

func _set_pickable(b):
	$MeshInstance3D/StaticBody3D.input_ray_pickable = b

func _set_unit(u:Unit):
	_place_unit(u)
	u._setup(1, S.P)

func _on_static_body_3d_input_event(_camera, event, _position, _normal, _shape_idx):
	if Shop_Unit == null:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed == true:
			#pickup/hold
			return
		elif event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
			#drop/buy if possible, otherwise snap back
			return

func _buy_unit(u):
	if S.P._spend(u.UStats.UCost):
		S.P._create_unit_ui(u)
		#add unit to player team comp
		#move to tile

func _place_unit(u:Unit):
	add_child(u)
	Shop_Unit = u

func _remove_unit():
	Shop_Unit.queue_free()
	Shop_Unit = null
