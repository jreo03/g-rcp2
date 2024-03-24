@tool
extends Control

class_name ViVeTorqueGraph

@export_category("Graph")
@export_group("Display Units")
@export_enum("ft⋅lb", "nm", "kg/m") var Torque_Unit:int = 1
@export_enum("hp", "bhp", "ps", "kW") var Power_Unit:int = 0

@export_group("ECU")
## Set this beyond the rev range to disable it, set it to 0 to use this vvt state permanently.
@export var IdleRPM:float = 800.0
## Set this beyond the rev range to disable it, set it to 0 to use this vvt state permanently.
@export var RPMLimit:float = 7000.0 
## Set this beyond the rev range to disable it, set it to 0 to use this vvt state permanently.
@export var VVTRPM:float = 4500.0

@export_group("Graph settings")
@export var graph_scale:float = 0.005
## How many points will be rendered to the graph. 
##Higher numbers will take longer to "render", but you get a more precise and detailed result.
@export var Generation_Range:float = 7000.0
@export var Draw_RPM:float = 800.0

var peakhp:Array[float] = [0.0,0.0]
var peaktq:Array[float] = [0.0,0.0]

@export var car:ViVeCar = null

@onready var torque:Line2D = $power_graph/torque
@onready var torque_p:Polygon2D = $power_graph/torque/peak
@onready var power:Line2D = $power_graph/power
@onready var power_p:Polygon2D = $power_graph/power/peak

var temp_rpm_fix:float = 0.0

func draw_graph() -> void:
	#Some checks I've found are necessary
	if not is_instance_valid(car):
		print("Car instance is not valid")
		return
#	elif car.get("_rpm") == null:
#		print("'_rpm' could not be found in given car, drawing cannot proceed.")
#		return
	
	peakhp = [0.0,0.0]
	peaktq = [0.0,0.0]
	torque.clear_points()
	power.clear_points()
	var skip:int = 0
	#var draw_scale:Vector2 = Vector2(size.x / Generation_Range, size.y / Generation_Range) 
	for i:int in range(Generation_Range):
		if i > Draw_RPM:
			car._rpm = float(i)
			#var trq:float = VitaVehicleSimulation.multivariate(car)
			var trq:float = car.multivariate()
			var hp:float = (i / 5252.0) * trq
			
			if Torque_Unit == 1:
				trq *= 1.3558179483
			elif Torque_Unit == 2:
				trq *= 0.138255
			
			match Power_Unit:
				1:
					hp *= 0.986
				2:
					hp *= 1.01387
				3:
					hp *= 0.7457
			
			var tr_p:Vector2 = Vector2((i / Generation_Range) * size.x, size.y - (trq * size.y) * graph_scale)
			var hp_p:Vector2 = Vector2((i / Generation_Range) * size.x, size.y - (hp * size.y) * graph_scale)
			
			if hp > peakhp[0]:
				peakhp = [hp, i]
				power_p.position = hp_p
			
			if trq > peaktq[0]:
				peaktq = [trq, i]
				torque_p.position = tr_p
			
			skip -= 1
			if skip <= 0:
				torque.add_point(tr_p)
				power.add_point(hp_p)
				skip = 100
