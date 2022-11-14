tool
extends Control

export(int, "ft⋅lb", "nm", "kg/m") var Torque_Unit = 1
export(int, "hp", "bhp", "ps", "kW") var Power_Unit = 0


#engine
export var RevSpeed = 2.0 # Flywheel lightness
export var EngineFriction = 18000.0
export var EngineDrag = 0.006

#ECU
export var IdleRPM = 800.0 # set this beyond the rev range to disable it, set it to 0 to use this vvt state permanently
export var RPMLimit = 7000.0 # set this beyond the rev range to disable it, set it to 0 to use this vvt state permanently
export var VVTRPM = 4500.0 # set this beyond the rev range to disable it, set it to 0 to use this vvt state permanently

#torque normal state
export var BuildUpTorque = 0.0035
export var TorqueRise = 30.0
export var RiseRPM = 1000.0
export var OffsetTorque = 110
export var FloatRate = 0.1
export var DeclineRate = 1.5
export var DeclineRPM = 3500.0
export var DeclineSharpness = 1.0

#torque export variable valve timing triggered
export var VVT_BuildUpTorque = 0.0
export var VVT_TorqueRise = 60.0
export var VVT_RiseRPM = 1000.0
export var VVT_OffsetTorque = 70
export var VVT_FloatRate = 0.1
export var VVT_DeclineRate = 2.0
export var VVT_DeclineRPM = 5000.0
export var VVT_DeclineSharpness = 1.0

export var TurboEnabled = false
export var MaxPSI = 9.0
export var TurboAmount = 1 # Turbo power multiplication.
export var EngineCompressionRatio = 8.0 # Piston travel distance
export var SuperchargerEnabled = false # Enables supercharger
export var SCRPMInfluence = 1.0
export var BlowRate = 35.0
export var SCThreshold = 6.0


export var scale = 0.005
export var Generation_Range = 7000.0
export var Draw_RPM = 800.0

var peakhp = [0.0,0.0]
var peaktq = [0.0,0.0]

func draw_():

	peakhp = [0.0,0.0]
	peaktq = [0.0,0.0]
	$torque.clear_points()
	$power.clear_points()
	var skip = 0
	for i in range(Generation_Range):
		if i>Draw_RPM:
			var tr = VitaVehicleSimulation.multivariate(RiseRPM,TorqueRise,BuildUpTorque,EngineFriction,EngineDrag,OffsetTorque,i,DeclineRPM,DeclineRate,FloatRate,MaxPSI,TurboAmount,EngineCompressionRatio,TurboEnabled,VVTRPM,VVT_BuildUpTorque,VVT_TorqueRise,VVT_RiseRPM,VVT_OffsetTorque,VVT_FloatRate,VVT_DeclineRPM,VVT_DeclineRate,SuperchargerEnabled,SCRPMInfluence,BlowRate,SCThreshold,DeclineSharpness,VVT_DeclineSharpness)
			var hp = (i/5252.0)*tr
			
			if Torque_Unit == 1:
				tr *= 1.3558179483
			elif Torque_Unit == 2:
				tr *= 0.138255
			
			if Power_Unit == 1:
				hp *= 0.986
			elif Power_Unit == 2:
				hp *= 1.01387
			elif Power_Unit == 3:
				hp *= 0.7457
			
			var tr_p = Vector2((i/Generation_Range)*rect_size.x,rect_size.y -(tr*rect_size.y)*scale)
			var hp_p = Vector2((i/Generation_Range)*rect_size.x,rect_size.y -(hp*rect_size.y)*scale)
			
			if hp>peakhp[0]:
				peakhp = [hp,i]
				$power/peak.position = hp_p
				
			if tr>peaktq[0]:
				peaktq = [tr,i]
				$torque/peak.position = tr_p
			
			skip -= 1
			if skip<=0:
				$torque.add_point(tr_p)
				$power.add_point(hp_p)
				skip = 100
