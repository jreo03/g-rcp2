tool
extends Node

var misc_smoke = true

var GearAssistant = 2 # 0 = manual, 1 = semi-manual, 2 = auto

var UseMouseSteering = false
var UseAccelerometreSteering = false
var SteerSensitivity = 1.0
var KeyboardSteerSpeed = 0.025
var KeyboardReturnSpeed = 0.05
var KeyboardCompensateSpeed = 0.1

var SteerAmountDecay = 0.0125 # understeer help
var SteeringAssistance = 1.0
var SteeringAssistanceAngular = 0.25

var OnThrottleRate = 0.2
var OffThrottleRate = 0.2

var OnBrakeRate = 0.05
var OffBrakeRate = 0.1

var OnHandbrakeRate = 0.2
var OffHandbrakeRate = 0.2

var OnClutchRate = 0.2
var OffClutchRate = 0.2



func multivariate(RiseRPM,TorqueRise,BuildUpTorque,EngineFriction,EngineDrag,OffsetTorque,RPM,DeclineRPM,DeclineRate,FloatRate,PSI,TurboAmount,EngineCompressionRatio,TEnabled,VVTRPM,VVT_BuildUpTorque,VVT_TorqueRise,VVT_RiseRPM,VVT_OffsetTorque,VVT_FloatRate,VVT_DeclineRPM,VVT_DeclineRate,SCEnabled,SCRPMInfluence,BlowRate,SCThreshold,DeclineSharpness,VVT_DeclineSharpness):
	var value = 0.0
	
	var maxpsi = 0.0
	var scrpm = 0.0
	var f = 0.0
	var j = 0.0
	
	if SCEnabled:
		maxpsi = PSI
		scrpm = RPM*SCRPMInfluence
		PSI = (scrpm/10000.0)*BlowRate -SCThreshold
		if PSI>maxpsi:
			 PSI = maxpsi
		if PSI<0.0:
			 PSI = 0.0
	 
	if not SCEnabled and not TEnabled:
		 PSI = 0.0

	if RPM>VVTRPM:
		value = (RPM*VVT_BuildUpTorque +VVT_OffsetTorque) + ( (PSI*TurboAmount) * (EngineCompressionRatio*0.609) )
		f = RPM-VVT_RiseRPM
		if f<0.0:
			f = 0.0
		value += (f*f)*(VVT_TorqueRise/10000000.0)
		j = RPM-VVT_DeclineRPM
		if j<0.0:
			j = 0.0
		value /= (j*(j*VVT_DeclineSharpness +(1.0-VVT_DeclineSharpness)))*(VVT_DeclineRate/10000000.0) +1.0
		value /= (RPM*RPM)*(VVT_FloatRate/10000000.0) +1.0
	else:
		value = (RPM*BuildUpTorque +OffsetTorque) + ( (PSI*TurboAmount) * (EngineCompressionRatio*0.609) )
		f = RPM-RiseRPM
		if f<0.0:
			f = 0.0
		value += (f*f)*(TorqueRise/10000000.0)
		j = RPM-DeclineRPM
		if j<0.0:
			j = 0.0
		value /= (j*(j*DeclineSharpness +(1.0-DeclineSharpness)))*(DeclineRate/10000000.0) +1.0
		value /= (RPM*RPM)*(FloatRate/10000000.0) +1.0

	value -= RPM/((abs(RPM*RPM))/EngineFriction +1.0)
	value -= RPM*EngineDrag
	
	
	
	return value


func fastest_wheel(array):
	var val = -10000000000000000000000000000000000.0
	var obj
	
	for i in array:
		val = max(val, abs(i.absolute_wv))
		
		if val == abs(i.absolute_wv):
			obj = i

	return obj

func slowest_wheel(array):
	var val = 10000000000000000000000000000000000.0
	var obj
	
	for i in array:
		val = min(val, abs(i.absolute_wv))
		
		if val == abs(i.absolute_wv):
			obj = i

	return obj

func alignAxisToVector(xform, norm): # i named this literally out of blender
	xform.basis.y = norm
	xform.basis.x = -xform.basis.z.cross(norm)
	xform.basis = xform.basis.orthonormalized()
	return xform


func suspension(own,maxcompression,incline_free,incline_impact,rest,      elasticity,damping,damping_rebound     ,linearz,g_range,located,hit_located,weight,ground_bump,ground_bump_height):
	own.get_node("geometry").global_translation = own.get_collision_point()
	own.get_node("geometry").translation.y -= (ground_bump*ground_bump_height)
	if own.get_node("geometry").translation.y<-g_range:
		own.get_node("geometry").translation.y = -g_range
	own.get_node("velocity").global_transform = alignAxisToVector(own.get_node("velocity").global_transform,own.get_collision_normal())
	own.get_node("velocity2").global_transform = alignAxisToVector(own.get_node("velocity2").global_transform,own.get_collision_normal())

	own.angle = (own.get_node("geometry").rotation_degrees.z -(-own.c_camber*float(own.translation.x>0.0) + own.c_camber*float(own.translation.x<0.0)) +(-own.cambered*float(own.translation.x>0.0) + own.cambered*float(own.translation.x<0.0))*own.A_Geometry2)/90.0

	var incline = (own.get_collision_normal()-own.global_transform.basis.orthonormalized().xform(Vector3(0,1,0))).length()
		
	incline /= 1-incline_free
	
	incline -= incline_free

	if incline<0.0:
		incline = 0.0

	incline *= incline_impact

	if incline>1.0:
		incline = 1.0

	if own.get_node("geometry").translation.y>-g_range +maxcompression*(1.0-incline):
		own.get_node("geometry").translation.y = -g_range +maxcompression*(1.0-incline)

	var damp_variant = damping_rebound
	if linearz<0:
		 damp_variant = damping

	var compressed = g_range -(located - hit_located).length() - (ground_bump*ground_bump_height)
	var compressed2 = g_range -(located - hit_located).length() - (ground_bump*ground_bump_height)
	compressed2 -= maxcompression + (ground_bump*ground_bump_height)

	var j = compressed-rest
	
	if j<0.0:
		 j = 0.0

	if compressed2<0.0:
		 compressed2 = 0.0

	var elasticity2 = elasticity*(1.0-incline) + (weight)*incline
	var damping2 = damp_variant*(1.0-incline) + (weight/10.0)*incline
	var elasticity3 = weight
	var damping3 = weight/10.0
	var suspforce = j*elasticity2

	if compressed2>0.0:
		suspforce -= linearz*damping3
		suspforce += compressed2*elasticity3

	suspforce -= linearz*damping2

	own.rd = compressed

	if suspforce<0.0:
		suspforce = 0.0

	return suspforce

