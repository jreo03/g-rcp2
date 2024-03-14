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

#torque normal state
@export var BuildUpTorque:float = 0.0035
@export var TorqueRise:float = 30.0
@export var RiseRPM:float = 1000.0
@export var OffsetTorque = 110
@export var FloatRate:float = 0.1
@export var DeclineRate:float = 1.5
@export var DeclineRPM:float = 3500.0
@export var DeclineSharpness:float = 1.0

#torque @export variable valve timing triggered
@export var VVT_BuildUpTorque:float = 0.0
@export var VVT_TorqueRise:float = 60.0
@export var VVT_RiseRPM:float = 1000.0
@export var VVT_OffsetTorque = 70
@export var VVT_FloatRate:float = 0.1
@export var VVT_DeclineRate:float = 2.0
@export var VVT_DeclineRPM:float = 5000.0
@export var VVT_DeclineSharpness:float = 1.0

@export var TurboEnabled:bool = false
@export var MaxPSI:float = 9.0
@export var TurboAmount = 1 # Turbo power multiplication.
@export var EngineCompressionRatio:float = 8.0 # Piston travel distance
@export var SuperchargerEnabled:bool = false # Enables supercharger
@export var SCRPMInfluence:float = 1.0
@export var BlowRate:float = 35.0
@export var SCThreshold:float = 6.0


@export var graph_scale:float = 0.005
@export var Generation_Range:float = 7000.0
@export var Draw_RPM:float = 800.0

var peakhp:Array[float] = [0.0,0.0]
var peaktq:Array[float] = [0.0,0.0]

@export var car:ViVeCar = ViVeCar.new()

func draw_():
	peakhp = [0.0,0.0]
	peaktq = [0.0,0.0]
	$torque.clear_points()
	$power.clear_points()
	var skip:int = 0
	for i in range(Generation_Range):
		if i > Draw_RPM:
			#var tr = VitaVehicleSimulation.multivariate(RiseRPM,TorqueRise,BuildUpTorque,EngineFriction,EngineDrag,OffsetTorque,i,DeclineRPM,DeclineRate,FloatRate,MaxPSI,TurboAmount,EngineCompressionRatio,TurboEnabled,VVTRPM,VVT_BuildUpTorque,VVT_TorqueRise,VVT_RiseRPM,VVT_OffsetTorque,VVT_FloatRate,VVT_DeclineRPM,VVT_DeclineRate,SuperchargerEnabled,SCRPMInfluence,BlowRate,SCThreshold,DeclineSharpness,VVT_DeclineSharpness)
			car.RPM = i
			var tr:float = VitaVehicleSimulation.multivariate(car)
			var hp:float = (i / 5252.0) * tr
			
			if Torque_Unit == 1:
				tr *= 1.3558179483
			elif Torque_Unit == 2:
				tr *= 0.138255
			
			match Power_Unit:
				1:
					hp *= 0.986
				2:
					hp *= 1.01387
				3:
					hp *= 0.7457
			
			var tr_p:Vector2 = Vector2((i / Generation_Range) * size.x, size.y - (tr * size.y) * graph_scale)
			var hp_p:Vector2 = Vector2((i / Generation_Range) * size.x, size.y - (hp * size.y) * graph_scale)
			
			if hp > peakhp[0]:
				peakhp = [hp,i]
				$power/peak.position = hp_p
			
			if tr > peaktq[0]:
				peaktq = [tr,i]
				$torque/peak.position = tr_p
			
			skip -= 1
			if skip <= 0:
				$torque.add_point(tr_p)
				$power.add_point(hp_p)
				skip = 100
