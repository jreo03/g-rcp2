@tool
extends Node

#This is VitaVehicleSimulation

var misc_smoke:bool = true

enum GearAssist {
	Manual = 0,
	Semi_manual = 1,
	Auto = 2,
}

var GearAssistss:int = 2 # 0 = manual, 1 = semi-manual, 2 = auto

@export var universal_controls:ViVeCarControls = ViVeCarControls.new()

const multivariation_inputs:PackedStringArray = [
"RiseRPM","TorqueRise","BuildUpTorque","EngineFriction",
"EngineDrag","OffsetTorque","RPM","DeclineRPM","DeclineRate",
"FloatRate","PSI","TurboAmount","EngineCompressionRatio",
"TEnabled","VVTRPM","VVT_BuildUpTorque","VVT_TorqueRise",
"VVT_RiseRPM","VVT_OffsetTorque","VVT_FloatRate",
"VVT_DeclineRPM","VVT_DeclineRate","SCEnabled",
"SCRPMInfluence","BlowRate","SCThreshold",
"DeclineSharpness","VVT_DeclineSharpness"
]

func multivariate(car:ViVeCar) -> float:
	
	var value:float = 0.0
	
	var maxpsi:float = 0.0
	var scrpm:float = 0.0
	var f:float = 0.0
	var j:float = 0.0
	
	if car.SCEnabled:
		maxpsi = car.PSI
		scrpm = car.RPM * car.SCRPMInfluence
		car.PSI = (scrpm / 10000.0) * car.BlowRate - car.SCThreshold
		car.PSI = clampf(car.PSI, 0.0, maxpsi)
	
	if not car.SCEnabled and not car.TEnabled:
		car.PSI = 0.0
	
	var torque_local:ViVeCarTorque 
	if car.RPM > car.VVTRPM:
		torque_local = car.torque_vvt
	else:
		torque_local = car.torque_norm
	
	value = (car.RPM * torque_local.BuildUpTorque + torque_local.OffsetTorque) + ( (car.PSI * car.TurboAmount) * (car.EngineCompressionRatio * 0.609) )
	f = car.RPM - torque_local.RiseRPM
	f = maxf(f, 0.0)
	
	value += (f * f) * (torque_local.TorqueRise / 10000000.0)
	j = car.RPM - torque_local.DeclineRPM
	j = maxf(j, 0.0)
	
	value /= (j * (j * torque_local.DeclineSharpness + (1.0 - torque_local.DeclineSharpness))) * (torque_local.DeclineRate / 10000000.0) + 1.0
	value /= (car.RPM * car.RPM) * (torque_local.FloatRate / 10000000.0) + 1.0
	
	value -= car.RPM / ((abs(car.RPM * car.RPM)) / car.EngineFriction + 1.0)
	value -= car.RPM * car.EngineDrag
	
	return value

func fastest_wheel(array:Array[ViVeWheel]) -> ViVeWheel:
	var val:float = -10000000000000000000000000000000000.0
	var obj:ViVeWheel
	
	for i:ViVeWheel in array:
		val = max(val, abs(i.absolute_wv))
		
		if val == abs(i.absolute_wv):
			obj = i
	
	return obj

func slowest_wheel(array:Array[ViVeWheel]) -> ViVeWheel:
	var val:float = 10000000000000000000000000000000000.0
	var obj:ViVeWheel
	
	for i:ViVeWheel in array:
		val = min(val, abs(i.absolute_wv))
		
		if val == abs(i.absolute_wv):
			obj = i
	
	return obj

func alignAxisToVector(xform:Transform3D, norm:Vector3) -> Transform3D: # i named this literally out of blender
	xform.basis.y = norm
	xform.basis.x = -xform.basis.z.cross(norm)
	xform.basis = xform.basis.orthonormalized()
	return xform

