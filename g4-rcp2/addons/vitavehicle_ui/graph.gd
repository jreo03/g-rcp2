@tool
extends Control

@export_enum("ft⋅lb", "nm", "kg/m") var Torque_Unit = 1
@export_enum("hp", "bhp", "ps", "kW") var Power_Unit = 0


#engine
@export var RevSpeed = 2.0 # Flywheel lightness
@export var EngineFriction = 18000.0
@export var EngineDrag = 0.006

#ECU
@export var IdleRPM:float = 800.0 # set this beyond the rev range to disable it, set it to 0 to use this vvt state permanently
@export var RPMLimit:float = 7000.0 # set this beyond the rev range to disable it, set it to 0 to use this vvt state permanently
@export var VVTRPM:float = 4500.0 # set this beyond the rev range to disable it, set it to 0 to use this vvt state permanently

@export var graph_scale:float = 0.005
@export var Generation_Range:float = 7000.0
@export var Draw_RPM:float = 800.0

var peakhp:Array[float] = [0.0,0.0]
var peaktq:Array[float] = [0.0,0.0]

@export var car:ViVeCar = ViVeCar.new()

func draw_() -> void:
	peakhp = [0.0,0.0]
	peaktq = [0.0,0.0]
	$torque.clear_points()
	$power.clear_points()
	var skip:int = 0
	for i in range(Generation_Range):
		if i > Draw_RPM:
			car._rpm = i
			var trq:float = VitaVehicleSimulation.multivariate(car)
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
				$power/peak.position = hp_p
			
			if trq > peaktq[0]:
				peaktq = [trq, i]
				$torque/peak.position = tr_p
			
			skip -= 1
			if skip <= 0:
				$torque.add_point(tr_p)
				$power.add_point(hp_p)
				skip = 100
