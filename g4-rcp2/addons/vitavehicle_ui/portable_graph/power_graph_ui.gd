@tool
extends Control

var constant_refresh:bool = false

@onready var graph:ViVeTorqueGraph = $HSplitContainer/graph

func _process(_delta: float) -> void:
	if constant_refresh:
		_on_refresh_pressed()

func _on_car_select_pressed() -> void:
	var nods:Array[Node] = EditorInterface.get_selection().get_selected_nodes()
	#TODO: Make this check a lot more... check-y (not as glaringly scuffed and flawed)
	if nods.size() == 1 && nods[0].get_class() == "RigidBody3D": #RigidBody3D is the base class of ViVeCar
		graph.car = nods[0] as ViVeCar
		nods[0].get_script()
	else:
		graph.car = ViVeCar.new()

func _on_refresh_pressed() -> void:
	graph.draw_graph()

func _on_constant_toggled(toggled_on: bool) -> void:
	constant_refresh = toggled_on

func _on_torque_unit_item_selected(index: int) -> void:
	graph.Torque_Unit = index

func _on_power_unit_item_selected(index: int) -> void:
	graph.Power_Unit = index
