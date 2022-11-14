tool
extends VBoxContainer

var generated = false

onready var vari = $vari.duplicate()
onready var desc = $desc.duplicate()
onready var type = $type.duplicate()
onready var cat1 = $category1.duplicate()
onready var cat2 = $category2.duplicate()

var controls = {
	"Use_Global_Control_Settings": ["Applies all control settings globally. This also affects cars that were already spawned.",false],
	"UseMouseSteering": ["Uses your cursor to steer the vehicle.",false],
	"UseAccelerometreSteering": ["Uses your accelerometre to steer, typically on mobile devices that have them.",false],
	"SteerSensitivity": ["Steering amplification on mouse and accelerometre steering.",0.0],

	"KeyboardSteerSpeed": ["Keyboard steering response rate.",0.0],
	"KeyboardReturnSpeed": ["Keyboard steering centring rate.",0.0],
	"KeyboardCompensateSpeed": ["Return rate when steering from an opposite direction.",0.0],
	"SteerAmountDecay": ["Reduces steering rate based on the vehicle’s speed.",0.0],
	"SteeringAssistance": ["Drift Help",0.0],
	"SteeringAssistanceAngular": ["Drift Stability Help",0.0],
	"GearAssistant": ["Gear Assistance (see below)",Array([])],
	"GearAssistant[0]": ["Shift Delay",0],
	"GearAssistant[1]": ["Assistance Level (0 - 2)",0],
	"GearAssistant[2]": ["Speed influence relative to wheel sizes. (This will be set automatically)",0.0],
	"GearAssistant[3]": ["Downshift RPM",0.0],
	"GearAssistant[4]": ["Upshift RPM",0.0],
	"GearAssistant[5]": ["Clutch-Out RPM",0.0],
	"OnThrottleRate": ["Throttle Pressure Rate",0.0],
	"OffThrottleRate": ["Throttle Depress Rate",0.0],
	"OnBrakeRate": ["Brake Pressure Rate",0.0],
	"OffBrakeRate": ["Brake Depress Rate",0.0],
	"OnHandbrakeRate": ["Handbrake Pull Rate",0.0],
	"OffHandbrakeRate": ["Handbrake Push Rate",0.0],
	"OnClutchRate": ["Clutch Release Rate",0.0],
	"OffClutchRate": ["Clutch Engage Rate",0.0],
	"MaxThrottle": ["Button Maximum Throttle Amount",0.0],
	"MaxBrake": ["Button Maximum Brake Amount",0.0],
	"MaxHandbrake": ["Button Maximum Handbrake Amount",0.0],
	"MaxClutch": ["Button Maximum Clutch Amount",0.0],
}
var chassis = {
	"Weight": ["Vehicle weight in kilograms.",0.0],
}
var body = {
	"LiftAngle": ["Up-pitch force based on the car’s velocity.",0.0],
	"DragCoefficient": ["A force moving opposite in relation to the car’s velocity.",0.0],
	"Downforce": ["A force moving downwards in relation to the car’s velocity.",0.0],
}
var steering = {
	"AckermanPoint": ["The longitudinal pivot point from the car’s geometry (measured in default unit scale).",0.0],
	"Steer_Radius": ["Minimum turning circle (measured in default unit scale).",0.0],
}
var dt = {
	"Powered_Wheels": ["A set of wheels that are powered parented under the vehicle.",PoolStringArray()],
	"DSWeight": ["Leave this.",PoolStringArray()],
	"FinalDriveRatio": ['"Final Drive Ratio refers to the last set of gears that connect a vehicle%ss engine to the driving axle."' % "'",0.0],
	"GearRatios": ['A set of gears a vehicle%ss transmission has in order. "A gear ratio is the ratio of the number of rotations of a driver gear to the number of rotations of a driven gear."' % "'",PoolRealArray()],
	"ReverseRatio": ["The reversed equivalent to GearRatios, only containing one gear.",0.0],
	"RatioMult": ["Similar to FinalDriveRatio, but this should not relate to any real-life data. You may keep the value as it is.",0.0],
	"StressFactor": ["The amount of stress put into the transmission (as in accelerating or decelerating) to restrict clutchless gear shifting.",0.0],
	"GearGap": ["A space between the teeth of all gears to perform clutchless gear shifts. Higher values means more noise. Compensate with StressFactor.",0.0],
	"TransmissionType": ["Selection of transmission types that are implemented in VitaVehicle.",0],
	"AutoSettings": ["Transmission automation settings (for Automatic, CVT and Semi-Auto).",[]],
	"AutoSettings[0]": ["Upshift RPM",0.0],
	"AutoSettings[1]": ["Downshift Threshold",0.0],
	"AutoSettings[2]": ["",0.0],
	"AutoSettings[3]": ["",0.0],
	"AutoSettings[4]": ["",0.0],
	"CVTSettings": ["Settings for CVT.",[]],
	"CVTSettings[0]": ["",0.0],
	"CVTSettings[1]": ["",0.0],
	"CVTSettings[2]": ["",0.0],
	"CVTSettings[3]": ["",0.0],
	"CVTSettings[4]": ["",0.0],
	"CVTSettings[5]": ["",0.0],
}
var stab = {
	"ABS": ["Anti-lock Braking System (see below)",[]],
	"ABS[0]": ["Threshold",0.0],
	"ABS[1]": ["Pump Time",0],
	"ABS[2]": ["Vehicle Speed Before Activation",0.0],
	"ABS[3]": ["Enabled",false],
	"ESP": ["Electronic Stability Program.\n\nCURRENTLY DOESN'T WORK",[]],
	"BTCS": ["Prevents wheel slippage using the brakes.\n\nCURRENTLY DOESN'T WORK",[]],
	"TTCS": ["Prevents wheel slippage by partially closing the throttle.\n\nCURRENTLY DOESN'T WORK",[]],
}
var diff = {
	"Locking": ["Locks differential under acceleration.",0.0],
	"CoastLocking": ["Locks differential under deceleration.",0.0],
	"Preload": ["Static differential locking. (0.0 - 1.0)",0.0],

	"Centre_Locking": ["Locks centre differential under acceleration.",0.0],
	"Centre_CoastLocking": ["Locks centre differential under deceleration.",0.0],
	"Centre_Preload": ["Static centre differential locking. (0.0 - 1.0)",0.0],
}
var engine = {
	"RevSpeed": ["Flywheel Lightness",0.0],
	"EngineFriction": ["Chance of stalling.",0.0],
	"EngineDrag": ["Rev drop rate.",0.0],
	"ThrottleResponse": ["How instant the engine corresponds with throttle input. (0.0 - 1.0)",0.0],
	"DeadRPM": ["RPM below this threshold would stall the engine.",0.0],
}
var ecu = {
	"RPMLimit": ["Throttle Cutoff RPM",0.0],
	"LimiterDelay": ["Throttle cutoff time",0],
	"ThrottleLimit": ["Minimum throttle cutoff. (0.0 - 1.0)",0.0],
	"ThrottleIdle": ["Throttle intake on idle. (0.0 - 1.0)",0.0],
	"VVTRPM": ["Timing on RPM.",0.0],
}
var v1 = {
	"BuildUpTorque": ["Torque buildup relative to RPM.",0.0],
	"TorqueRise": ["Sqrt torque buildup relative to RPM.",0.0],
	"RiseRPM": ["Initial RPM for TorqueRise.",0.0],
	"OffsetTorque": ["Static torque.",0.0],
	"FloatRate": ["Torque reduction relative to RPM.",0.0],
	"DeclineRate": ["Rapid reduction of torque.",0.0],
	"DeclineRPM": ["Initial RPM for DeclineRate.",0.0],
}
var v2 = {
	"VVT_BuildUpTorque": ["See BuildUpTorque.",0.0],
	"VVT_TorqueRise": ["See TorqueRise.",0.0],
	"VVT_RiseRPM": ["See RiseRPM.",0.0],
	"VVT_OffsetTorque": ["See OffsetTorque.",0.0],
	"VVT_FloatRate": ["See FloatRate.",0.0],
	"VVT_DeclineRate": ["See DeclineRate.",0.0],
	"VVT_DeclineRPM": ["See DeclineRPM.",0.0],
}
var clutch = {
	"ClutchStable": ["Fix for engine's responses to friction. Higher values would make it sluggish.",0.0],
	"GearRatioRatioThreshold": ["Usually on a really short gear, the engine would jitter. This fixes it to say the least.",0.0],
	"ThresholdStable": ["Fix correlated to GearRatioRatioThreshold. Keep this value as it is.",0.0],
	"ClutchGrip": ["Clutch Capacity (nm)",0.0],
	"ClutchFloatReduction": ['Prevents RPM "Floating". This gives a better sensation on accelerating. Setting it too high would reverse the "floating". Setting it to 0 would turn it off.',0.0],

	"ClutchWobble": ["",0.0],
	"ClutchElasticity": ["",0.0],
	"WobbleRate": ["",0.0],
}
var forced = {
	"MaxPSI": ["Maximum air generated by any forced inductions.",0.0],
	"EngineCompressionRatio": ["Compression ratio has an effect on forced induction systems. This is only an information for VitaVehicle to read boosts and it doesn't affect torque when TurboEnabled is off.",0.0],
	"TurboEnabled": ["Turbocharger",false],
	"TurboAmount": ["Amount of turbochargers, multiplies boost power.",0.0],
	"TurboSize": ["Turbo Lag",0.0],
	"Compressor": ["Counters TurboSize",0.0],
	"SpoolThreshold": ["Threshold of throttle before spooling.",0.0],
	"BlowoffRate": ["How instant spooling stops.",0.0],
	"TurboEfficiency": ["Turbo Response",0.0],
	"TurboVacuum": ["Allowing Negative PSI",0.0],
	"SuperchargerEnabled": ["Supercharger",false],
	"SCRPMInfluence": ["Boost applied upon engine speeds.",0.0],
	"BlowRate": ["Boost Amplification",0.0],
	"SCThreshold": ["Deadzone before boost.",0.0],
}

var wheel = {
	"Steer": ["Allows this wheel to steer.",0.0],
	"Differed_Wheel": ["Finds a wheel to correct itself to another, in favour of differential mechanics. (both wheels need to have their properties proposed to each other)",0.0],
	"W_PowerBias": ["Power Bias (when driven)",0.0],
	"TyrePressure": ["Tyre Pressure PSI (hypothetical)",0.0],
	"Camber": ["Camber Angle.",0.0],
	"Caster": ["Caster Angle.",0.0],
	"Toe": ["Toe-in Angle.",0.0],
	"SwayBarConnection": ["Connects a sway bar to the opposing axle. (both wheels should have their properties proposed to each other)",0.0],
	"S_Stiffness": ["Spring Force",0.0],
	"S_Damping": ["Compression Dampening",0.0],
	"S_ReboundDamping": ["Rebound Dampening",0.0],
	"S_RestLength": ["Suspension Deadzone",0.0],
	"S_MaxCompression": ["Compression Barrier",0.0],
	"A_InclineArea": ["",0.0],
	"A_ImpactForce": ["",0.0],
	"AR_Stiff": ["Anti-roll Stiffness",0.0],
	"AR_Elast": ["Anti-roll Reformation Rate",0.0],
	"B_Torque": ["Brake Force",0.0],
	"B_Bias": ["Brake Bias",0.0],
	"HB_Bias": ["Handbrake Bias",0.0],
	"A_Geometry": ["Axle Vertical Mounting Position",0.0],
	"A_Geometry2": ["Camber Gain Factor",0.0],
	"A_Geometry3": ["Axle lateral mounting position, affecting camber gain. High negative values may mount them outside.",0.0],
	"A_Geometry4": ["",0.0],
	"ContactABS": ["Allows the Anti-lock Braking System to monitor this wheel.",0.0],
	"ESP_Role": ["",0.0],
	"ContactBTCS": ["",0.0],
	"ContactTTCS": ["",0.0],
}

var cs = {
	"OptimumTemp": ["Optimum tyre temperature for maximum grip effect. (currently isn't used)",0.0],
	"Stiffness": ["",0.0],
	"TractionFactor": ["Higher value would reduce grip.",0.0],
	"DeformFactor": ["",0.0],
	"ForeFriction": ["",0.0],
	"ForeStiffness": ["",0.0],
	"GroundDragAffection": ["",0.0],
	"BuildupAffection": ["Increase in grip on loose surfaces.",0.0],
	"CoolRate": ["Tyre Cooldown Rate. (currently isn't used)",0.0],
}
var tyreset = {
	"GripInfluence": ["Grip and traction amplification",0.0],
	"Width (mm)": ["",0.0],
	"Aspect Ratio": ["%sAspect ratios are delivered in percentages. Tire makers calculate the aspect ratio by dividing a tire's height off the rim by its width. If a tire has an aspect ratio of 70, it means the tire's height is 70%s of its width.%s" % ['"',"%",'"'],0.0],
	"Rim Size (in)": ["", 0.0],
}

func type(n):
	var builtin_type_names = ["nil", "bool", "int", "float", "string", "vector2", "rect2", "vector3", "maxtrix32", "plane", "quat", "aabb",  "matrix3", "transform", "color", "image", "nodepath", "rid", null, "array", "dictionary", "array", "floatarray", "stringarray", "realarray", "stringarray", "vector2array", "vector3array", "colorarray", "unknown"]

	return builtin_type_names[n]

func add(categ,catname,descr):
	var cat = cat2.duplicate()
	add_child(cat)
	cat.text = catname+str(" +")
	cat.default_text = catname
	cat.visible = false
	var desc1 = desc.duplicate()
	add_child(desc1)
	desc1.text = descr
	desc1.visible = false
	cat.nodes.append(desc1)
	for i in categ:
		var v = vari.duplicate()
		add_child(v)
		v.text = i +str(" +")
		var d = desc.duplicate()
		add_child(d)
		d.text = "\n" +str(categ[i][0]) +str("\n")
		var t = type.duplicate()
		add_child(t)
		t.text = "Type: "+str(type( typeof(categ[i][1]) )) +str("\n")
		v.default_text = i
		v.nodes = [d,t]
		v.visible = false
		d.visible = false
		t.visible = false
		cat.nodes.append(v)

	return cat

func generate():
	if not generated:
		$vari.queue_free()
		$desc.queue_free()
		$type.queue_free()
		$category1.queue_free()
		$category2.queue_free()

		var car = cat1.duplicate()
		add_child(car)
		car.text = "car.gd +"
		car.default_text = "car.gd"
		car.nodes = [
			add(controls,"Controls", ""),
			add(chassis,"Chassis", ""),
			add(body,"Body", ""),
			add(steering,"Steering", ""),
			add(dt,"Drivetrain", ""),
			add(stab,"Stability (BETA)", ""),
			add(diff,"Differentials", ""),
			add(ecu,"ECU", ""),
			add(v1,"Configuration", ""),
			add(v2,"Configuration VVT","These variables are the second iteration. Vehicles will select these settings when RPMs reach a certain point (VVTRPM), portrayed as Variable Valve Timing."),
			add(clutch,"Clutch (BETA)", ""),
			add(forced,"Forced Inductions (BETA)", ""),
			]
		
		var wheels = cat1.duplicate()
		add_child(wheels)
		wheels.text = "wheel.gd +"
		wheels.default_text = "wheel.gd"
		wheels.nodes = [
			add(wheel,"General", ""),
			add(tyreset,"TyreSettings", ""),
			add(cs,"CompoundSettings", ""),
			]
		
		
		
		generated = true
