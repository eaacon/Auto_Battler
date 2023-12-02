extends Node3D

var Player = null

var Unit_On_Tile

@onready var Default_Mat = preload("res://Art/Materials/Default_Tile_Material.tres")
@onready var Selected_Mat = preload("res://Art/Materials/Default_Tile_Selected_Material.tres")


func _set_pickable(b):
	$MeshInstance3D/StaticBody3D.input_ray_pickable = b

func _on_static_body_3d_mouse_entered():
	if Player != null:
		$MeshInstance3D.material_override = Selected_Mat


func _on_static_body_3d_mouse_exited():
	if Player != null:
		$MeshInstance3D.material_override = Default_Mat


func _on_static_body_3d_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed == true:
			_place_unit()

func _place_unit():
	if Unit_On_Tile == null and Player != null:
		var inst = load("res://Scenes/Prefabs/Unit.tscn").instantiate()
		if(Player._spend(inst.UCost)):
			add_child(inst)
			Unit_On_Tile = inst
			print("Placed " + inst.name + " on " + self.name + " at " + str(position))
