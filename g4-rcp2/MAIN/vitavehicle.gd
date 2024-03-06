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

var UseMouseSteering:bool = false
var UseAccelerometreSteering:bool = false
var SteerSensitivity:float = 1.0
var KeyboardSteerSpeed:float = 0.025
var KeyboardReturnSpeed:float = 0.05
var KeyboardCompensateSpeed:float = 0.1

var SteerAmountDecay:float = 0.0125 # understeer help
var SteeringAssistance:float = 1.0
var SteeringAssistanceAngular:float = 0.25

var OnThrottleRate:float = 0.2
var OffThrottleRate:float = 0.2

var OnBrakeRate:float = 0.05
var OffBrakeRate:float = 0.1

var OnHandbrakeRate:float = 0.2
var OffHandbrakeRate:float = 0.2

var OnClutchRate:float = 0.2
var OffClutchRate:float = 0.2

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
	
	if car.RPM > car.VVTRPM:
		value = (car.RPM * car.VVT_BuildUpTorque + car.VVT_OffsetTorque) + ( (car.PSI * car.TurboAmount) * (car.EngineCompressionRatio * 0.609) )
		f = car.RPM - car.VVT_RiseRPM
		f = clampf(f, 0.0, INF)
		
		value += (f * f) * (car.VVT_TorqueRise / 10000000.0)
		j = car.RPM - car.VVT_DeclineRPM
		j = clampf(j, 0.0, INF)
		
		value /= (j * (j * car.VVT_DeclineSharpness + (1.0 - car.VVT_DeclineSharpness))) * (car.VVT_DeclineRate / 10000000.0) + 1.0
		value /= (car.RPM * car.RPM) * (car.VVT_FloatRate / 10000000.0) + 1.0
	else:
		value = (car.RPM * car.BuildUpTorque + car.OffsetTorque) + ( (car.PSI * car.TurboAmount) * (car.EngineCompressionRatio * 0.609) )
		f = car.RPM - car.RiseRPM
		f = clampf(f, 0.0, INF)

		value += (f * f) * (car.TorqueRise / 10000000.0)
		j = car.RPM - car.DeclineRPM
		
		j = clampf(j, 0.0, INF)
		
		value /= (j * (j * car.DeclineSharpness + (1.0 - car.DeclineSharpness))) * (car.DeclineRate / 10000000.0) + 1.0
		value /= (car.RPM * car.RPM) * (car.FloatRate / 10000000.0) + 1.0
	
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

func alignAxisToVector(xform, norm): # i named this literally out of blender
	xform.basis.y = norm
	xform.basis.x = -xform.basis.z.cross(norm)
	xform.basis = xform.basis.orthonormalized()
	return xform


func suspension(own,maxcompression,incline_free,incline_impact,rest,      elasticity,damping,damping_rebound     ,linearz,g_range,located,hit_located,weight,ground_bump,ground_bump_height) -> float:
	own.get_node("geometry").global_position = own.get_collision_point()
	own.get_node("geometry").position.y -= (ground_bump*ground_bump_height)
	if own.get_node("geometry").position.y < -g_range:
		own.get_node("geometry").position.y = -g_range
	own.get_node("velocity").global_transform = alignAxisToVector(own.get_node("velocity").global_transform,own.get_collision_normal())
	own.get_node("velocity2").global_transform = alignAxisToVector(own.get_node("velocity2").global_transform,own.get_collision_normal())
	
	own.angle = (own.get_node("geometry").rotation_degrees.z -(-own.c_camber*float(own.position.x>0.0) + own.c_camber*float(own.position.x<0.0)) +(-own.cambered*float(own.position.x>0.0) + own.cambered*float(own.position.x<0.0))*own.A_Geometry2)/90.0
	
#	var incline = (own.get_collision_normal()-own.global_transform.basis.orthonormalized().xform(Vector3(0,1,0))).length()
	var incline = (own.get_collision_normal()-(own.global_transform.basis.orthonormalized() * Vector3(0,1,0))).length()
		
	incline /= 1-incline_free
	
	incline -= incline_free
	
	incline = clampf(incline, 0.0, INF)
	
	incline *= incline_impact
	
	incline = clampf(incline, -INF, 1.0)
	
	if own.get_node("geometry").position.y>-g_range +maxcompression*(1.0-incline):
		own.get_node("geometry").position.y = -g_range +maxcompression*(1.0-incline)
	
	var damp_variant = damping_rebound
	if linearz < 0:
		damp_variant = damping
	
	var compressed = g_range - (located - hit_located).length() - (ground_bump*ground_bump_height)
	var compressed2 = g_range - (located - hit_located).length() - (ground_bump*ground_bump_height)
	compressed2 -= maxcompression + (ground_bump * ground_bump_height)
	
	var j = compressed - rest
	
	j = clamp(j, 0.0, INF)
	compressed2 = clamp(compressed2, 0.0, INF)
	
	var elasticity2:float = elasticity * (1.0 - incline) + (weight) * incline
	var damping2:float = damp_variant * (1.0 - incline) + (weight / 10.0) * incline
	var elasticity3:float = weight
	var damping3:float = weight / 10.0
	var suspforce:float = j * elasticity2
	
	if compressed2 > 0.0:
		suspforce -= linearz * damping3
		suspforce += compressed2 * elasticity3
	
	suspforce -= linearz * damping2
	
	own.rd = compressed
	
	suspforce = clampf(suspforce, 0.0, INF)
	
	return suspforce

