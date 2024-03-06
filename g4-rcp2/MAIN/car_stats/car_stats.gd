extends Resource
#For "VitaVehicle Car Stat Sheet
class_name ViVeCarSS

@export var Debug_Mode :bool = false

# controls
@export var Use_Global_Control_Settings:bool = false
@export var UseMouseSteering:bool = false
@export var UseAccelerometreSteering :bool = false
@export var SteerSensitivity:float = 1.0
@export var KeyboardSteerSpeed:float = 0.025
@export var KeyboardReturnSpeed:float = 0.05
@export var KeyboardCompensateSpeed:float = 0.1

@export var SteerAmountDecay:float = 0.015 # understeer help
@export var SteeringAssistance:float = 1.0
@export var SteeringAssistanceAngular:float = 0.12

@export var LooseSteering :bool = false #simulate rack and pinion steering physics (EXPERIMENTAL)

@export var OnThrottleRate:float = 0.2
@export var OffThrottleRate:float = 0.2

@export var OnBrakeRate:float = 0.05
@export var OffBrakeRate:float = 0.1

@export var OnHandbrakeRate:float = 0.2
@export var OffHandbrakeRate:float = 0.2

@export var OnClutchRate:float = 0.2
@export var OffClutchRate:float = 0.2

@export var MaxThrottle:float = 1.0
@export var MaxBrake:float = 1.0
@export var MaxHandbrake:float = 1.0
@export var MaxClutch:float = 1.0

#@export var GearAssistant:Array[float] = [
#20, # Shift delay
#2, # Assistance Level (0 - 2)
#0.944087, # Speed Influence (will be automatically set)
#6000.0, # Downshift RPM Iteration
#6200.0, # Upshift RPM
#3000.0, # Clutch-Out RPM
#5, # throttle input allowed after shiting delay
#]

# meta
@export var Controlled:bool = true

# chassis
@export var Weight:float = 900.0 # kg

# body
@export var LiftAngle:float = 0.1
@export var DragCoefficient:float = 0.25
@export var Downforce:float = 0.0

#steering
@export var AckermannPoint:float = -3.8
@export var Steer_Radius:float = 13.0

#drivetrain
@export var Powered_Wheels :Array[String] = ["fl","fr"]

@export var FinalDriveRatio:float = 4.250
@export var GearRatios :Array[float] = [ 3.250, 1.894, 1.259, 0.937, 0.771 ]
@export var ReverseRatio:float = 3.153

@export var RatioMult:float = 9.5
@export var StressFactor:float = 1.0
@export var GearGap:float = 60.0
@export var DSWeight:float = 150.0 # Leave this be, unless you know what you're doing.

@export_enum("Fully Manual", "Automatic", "Continuously Variable", "Semi-Auto") var TransmissionType:int = 0

enum TransmissionTypes {
	full_manual,
	auto,
	continuous_variable,
	semi_auto
}

@export var AutoSettings:Array[float] = [
6500.0, # shift rpm (auto)
300.0, # downshift threshold (auto)
0.5, # throttle efficiency threshold (range: 0 - 1) (auto/dct)
0.0, # engagement rpm threshold (auto/dct/cvt)
4000.0, # engagement rpm (auto/dct/cvt)
]

@export var CVTSettings:Array[float] = [
0.75, # throttle efficiency threshold (range: 0 - 1)
0.025, # acceleration rate (range: 0 - 1)
0.9, # iteration 1 (higher = higher rpm)
500.0, # iteration 2 (higher = better acceleration from standstill but unstable)
2.0, # iteration 3 (higher = longer it takes to "lock" the rpm)
0.2, # iteration 4 (keep it over 0.1)
]

#stability
@export var ABS:Array = [ # anti-lock braking system
2500.0, # threshold
1, # pump time
10, # vehicle speed before activation
true, # enabled
0.5, # pump force (0.0 - 1.0)
500.0, # lateral threshold
2, # lateral pump time
]

@export var ESP:Array = [ # electronic stability program
0.5, # stabilisation theshold
1.5, # stabilisation rate (higher = understeer, understeer = inefficient)
1, # yaw threshold
3.0, # yaw rate
false, # enableda
]

@export var BTCS:Array = [ # brake-based traction control system
10, # threshold
0.05, # sensitivity
false, # enabled
]

@export var TTCS:Array = [ # throttle-based traction control system
5, # threshold
1.0, # sensitivity
false, # enabled
]

#differentials
@export var Locking:float = 0.1
@export var CoastLocking:float = 0.0
@export var Preload:float = 0.0

@export var Centre_Locking:float = 0.5
@export var Centre_CoastLocking:float = 0.5
@export var Centre_Preload:float = 0.0

@export_group("Engine")
@export var RevSpeed:float = 2.0 # Flywheel lightness
@export var EngineFriction:float = 18000.0
@export var EngineDrag:float = 0.006
@export var ThrottleResponse:float = 0.5
@export var DeadRPM:float = 100.0

@export_group("ECU")
@export var RPMLimit:float = 7000.0
@export var LimiterDelay:float = 4
@export var IdleRPM:float = 800.0
@export var ThrottleLimit:float = 0.0
@export var ThrottleIdle:float = 0.25
@export var VVTRPM:float = 4500.0 # set this beyond the rev range to disable it, set it to 0 to use this vvt state permanently

@export_group('torque normal state')
@export var BuildUpTorque:float = 0.0035
@export var TorqueRise:float = 30.0
@export var RiseRPM:float = 1000.0
@export var OffsetTorque:float = 110.0
@export var FloatRate:float = 0.1
@export var DeclineRate:float = 1.5
@export var DeclineRPM:float = 3500.0
@export var DeclineSharpness:float = 1.0

@export_group("torque")
#@export variable valve timing triggered
@export var VVT_BuildUpTorque:float = 0.0
@export var VVT_TorqueRise:float = 60.0
@export var VVT_RiseRPM:float = 1000.0
@export var VVT_OffsetTorque:float = 70.0
@export var VVT_FloatRate:float = 0.1
@export var VVT_DeclineRate:float = 2.0
@export var VVT_DeclineRPM:float = 5000.0
@export var VVT_DeclineSharpness:float = 1.0

@export_group("clutch")
@export var ClutchStable:float = 0.5
@export var GearRatioRatioThreshold:float = 200.0
@export var ThresholdStable:float = 0.01
@export var ClutchGrip:float = 176.125
@export var ClutchFloatReduction:float = 27.0

@export var ClutchWobble:float = 2.5*0
@export var ClutchElasticity:float = 0.2*0
@export var WobbleRate:float = 0.0

#forced inductions
@export var MaxPSI:float = 9.0 # Maximum air generated by any forced inductions
@export var EngineCompressionRatio:float = 8.0 # Piston travel distance

#turbo
@export var TurboEnabled:bool = false # Enables turbo
@export var TurboAmount:float = 1 # Turbo power multiplication.
@export var TurboSize:float = 8.0 # Higher = More turbo lag
@export var Compressor:float = 0.3 # Higher = Allows more spooling on low RPM
@export var SpoolThreshold:float = 0.1 # Range: 0 - 0.9999
@export var BlowoffRate:float = 0.14
@export var TurboEfficiency:float = 0.075 # Range: 0 - 1
@export var TurboVacuum:float = 1.0 # Performance deficiency upon turbo idle

#supercharger
@export var SuperchargerEnabled:bool = false # Enables supercharger
@export var SCRPMInfluence:float = 1.0
@export var BlowRate:float = 35.0
@export var SCThreshold:float = 6.0

var rpm:float = 0.0
var rpmspeed:float = 0.0
var resistancerpm:float = 0.0
var resistancedv:float = 0.0
var gear:int = 0
var limdel:int = 0
var actualgear:int = 0
var gearstress:float = 0.0
var throttle:float = 0.0
var cvtaccel:float = 0.0
var sassistdel = 0
var sassiststep = 0
var clutchin:bool = false
var gasrestricted:bool = false
var revmatch:bool = false
var gaspedal:float = 0.0
var brakepedal:float = 0.0
var clutchpedal:float = 0.0
var clutchpedalreal:float = 0.0
var steer:float = 0.0
var steer2:float = 0.0
var abspump:float = 0.0
var tcsweight:float = 0.0
var tcsflash:bool = false
var espflash:bool = false
var ratio:float = 0.0
var vvt:bool = false
var brake_allowed:float = 0.0
var readout_torque:float = 0.0

var brakeline:float = 0.0
var handbrakepull:float = 0.0
var dsweight:float = 0.0
var dsweightrun:float = 0.0
var diffspeed:float = 0.0
var diffspeedun:float = 0.0
var locked:float = 0.0
var c_locked:float = 0.0
var wv_difference:float = 0.0
var rpmforce:float = 0.0
var whinepitch:float = 0.0
var turbopsi:float = 0.0
var scrpm:float = 0.0
var boosting:float = 0.0
var rpmcs:float = 0.0
var rpmcsm:float = 0.0
var currentstable:float = 0.0
var steering_geometry:Array[float] = [0.0,0.0]
var resistance:float = 0.0
var wob:float = 0.0
var ds_weight:float = 0.0
var steer_torque:float = 0.0
var steer_velocity:float = 0.0
var drivewheels_size:float = 1.0

var steering_angles:Array = []
var max_steering_angle:float = 0.0
var assistance_factor:float = 0.0

var pastvelocity:Vector3 = Vector3(0,0,0)
var gforce:Vector3 = Vector3(0,0,0)
var clock_mult:float = 1.0
var dist:float = 0.0
var stress:float = 0.0

var su:bool = false
var sd:bool = false
var gas:bool = false
var brake:bool = false
var handbrake:bool = false
var right:bool = false
var left:bool = false
var clutch:bool = false
var c_pws:Array = []

var velocity:Vector3 = Vector3(0,0,0)
var rvelocity:Vector3 = Vector3(0,0,0)

var stalled:float = 0.0

#added in for compatibility
var SCEnabled:bool
var TEnabled:bool
var PSI:float
var RPM:float #should be identical to its little case brother



#Whatever this does, it's best that its in this scope
func multivariate() -> float:
	var value:float = 0.0
	
	var maxpsi:float = 0.0
	#var scrpm:float = 0.0
	var f:float = 0.0
	var j:float = 0.0
	
	if SCEnabled:
		maxpsi = PSI
		scrpm = RPM * SCRPMInfluence
		PSI = (scrpm / 10000.0) * BlowRate - SCThreshold
		PSI = clampf(PSI, 0.0, maxpsi)
	
	if not SCEnabled and not TEnabled:
		PSI = 0.0
	
	if RPM > VVTRPM:
		value = (RPM * VVT_BuildUpTorque + VVT_OffsetTorque) + ( (PSI * TurboAmount) * (EngineCompressionRatio * 0.609) )
		f = RPM - VVT_RiseRPM
		f = clampf(f, 0.0, INF)
		
		value += (f * f) * (VVT_TorqueRise / 10000000.0)
		j = RPM - VVT_DeclineRPM
		j = clampf(j, 0.0, INF)
		
		value /= (j * (j * VVT_DeclineSharpness + (1.0 - VVT_DeclineSharpness))) * (VVT_DeclineRate / 10000000.0) + 1.0
		value /= (RPM * RPM) * (VVT_FloatRate / 10000000.0) + 1.0
	else:
		value = (RPM * BuildUpTorque + OffsetTorque) + ( (PSI * TurboAmount) * (EngineCompressionRatio * 0.609) )
		f = RPM - RiseRPM
		f = clampf(f, 0.0, INF)

		value += (f * f) * (TorqueRise / 10000000.0)
		j = RPM - DeclineRPM
		
		j = clampf(j, 0.0, INF)
		
		value /= (j * (j * DeclineSharpness + (1.0 - DeclineSharpness))) * (DeclineRate / 10000000.0) + 1.0
		value /= (RPM * RPM) * (FloatRate / 10000000.0) + 1.0
	
	value -= RPM / ((abs(RPM * RPM)) / EngineFriction + 1.0)
	value -= RPM * EngineDrag
	
	return value
