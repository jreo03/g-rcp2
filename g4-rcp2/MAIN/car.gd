extends RigidBody3D
##A class representing a car in VitaVehicle.
class_name ViVeCar

var c_pws:Array[ViVeWheel]

##A set of wheels that are powered parented under the vehicle.


@onready var front_left:ViVeWheel = $"fl"
@onready var front_right:ViVeWheel = $"fr"
@onready var back_left:ViVeWheel = $"rl"
@onready var back_right:ViVeWheel = $"rr"
@onready var drag_center:Marker3D = $"DRAG_CENTRE"

##An array containing the front wheels of the car.
@onready var front_wheels:Array[ViVeWheel] = [front_left, front_right]
##An array containing the rear wheels of the car.
@onready var rear_wheels:Array[ViVeWheel] = [back_left, back_right]

@export_group("Controls")
@export var car_controls:ViVeCarControls = ViVeCarControls.new()
var car_controls_cache:ViVeCarControls.ControlType
var _control_func:Callable = car_controls.controls_keyboard_mouse

## Gear Assistance.
@export var GearAssist:ViVeGearAssist = ViVeGearAssist.new()

@export_group("Meta")
#Whether the car is a user-controlled vehicle or not
@export var Controlled:bool = true
##Whether or not debug mode is active. [br]
##TODO: Make this do more than just hide weight distribution.
@export var Debug_Mode :bool = false

@export_group("Chassis")
##Vehicle weight in kilograms.
@export var Weight:float = 900.0 # kg

@export_group("Body")
##Up-pitch force based on the car’s velocity.
@export var LiftAngle:float = 0.1
##A force moving opposite in relation to the car’s velocity.
@export var DragCoefficient:float = 0.25
##A force moving downwards in relation to the car’s velocity.
@export var Downforce:float = 0.0

@export_group("Steering")
##The longitudinal pivot point from the car’s geometry (measured in default unit scale).
@export var AckermannPoint:float = -3.8
##Minimum turning circle (measured in default unit scale).
@export var Steer_Radius:float = 13.0

@export var Powered_Wheels:PackedStringArray = ["fl", "fr"]

@export_group("Drivetrain")
##Final Drive Ratio refers to the last set of gears that connect a vehicle's engine to the driving axle.
@export var FinalDriveRatio:float = 4.250
##A set of gears a vehicle%ss transmission has in order. [br]
##A gear ratio is the ratio of the number of rotations of a driver gear to the number of rotations of a driven gear.
@export var GearRatios :Array[float] = [ 3.250, 1.894, 1.259, 0.937, 0.771 ]
##The reversed equivalent to GearRatios, only containing one gear.
@export var ReverseRatio:float = 3.153
##Similar to FinalDriveRatio, but this should not relate to any real-life data. You may keep the value as it is.
@export var RatioMult:float = 9.5
##The amount of stress put into the transmission (as in accelerating or decelerating) to restrict clutchless gear shifting.
@export var StressFactor:float = 1.0
##A space between the teeth of all gears to perform clutchless gear shifts. Higher values means more noise. Compensate with StressFactor.
@export var GearGap:float = 60.0
## Leave this be, unless you know what you're doing.
@export var DSWeight:float = 150.0

##The [ViVeCar.TransmissionTypes] used for this car.
@export_enum("Fully Manual", "Automatic", "Continuously Variable", "Semi-Auto") var TransmissionType:int = 0

##Selection of transmission types that are implemented in VitaVehicle.
enum TransmissionTypes {
	full_manual = 0,
	auto = 1,
	continuous_variable = 2,
	semi_auto = 3
}

@export var AutoSettings:ViVeAutoSettings = ViVeAutoSettings.new()

## Settings for CVT.
@export var CVTSettings:ViVeCVT = ViVeCVT.new()

@export_group("Stability")
## Anti-lock Braking System. 
@export var ABS:ViVeABS = ViVeABS.new()
## @experimental 
## Electronic Stability Program. [br][br] CURRENTLY DOESN'T WORK!
@export var ESP:ViVeESP = ViVeESP.new()
## @experimental 
## Prevents wheel slippage using the brakes. [br] [br] CURRENTLY DOESN'T WORK!
@export var BTCS:ViVeBTCS = ViVeBTCS.new()
## @experimental 
## Prevents wheel slippage by partially closing the throttle. [br] [br] CURRENTLY DOESN'T WORK!
@export var TTCS:ViVeTTCS = ViVeTTCS.new()

@export_group("Differentials")
## Locks differential under acceleration.
@export var Locking:float = 0.1
## Locks differential under deceleration.
@export var CoastLocking:float = 0.0
## Static differential locking.
@export_range(0.0, 1.0) var Preload:float = 0.0
## Locks centre differential under acceleration.
@export var Centre_Locking:float = 0.5
## Locks centre differential under deceleration.
@export var Centre_CoastLocking:float = 0.5
## Static centre differential locking.
@export_range(0.0, 1.0) var Centre_Preload:float = 0.0

@export_group("Engine")
## Flywheel lightness.
@export var RevSpeed:float = 2.0 
## Chance of stalling.
@export var EngineFriction:float = 18000.0
## Rev drop rate.
@export var EngineDrag:float = 0.006
## How instant the engine corresponds with throttle input.
@export_range(0.0, 1.0) var ThrottleResponse:float = 0.5
## RPM below this threshold would stall the engine.
@export var DeadRPM:float = 100.0

@export_group("ECU")
## Throttle Cutoff RPM.
@export var RPMLimit:float = 7000.0
## Throttle cutoff time.
@export var LimiterDelay:float = 4

@export var IdleRPM:float = 800.0
## Minimum throttle cutoff.
@export_range(0.0, 1.0) var ThrottleLimit:float = 0.0
## Throttle intake on idle.
@export_range(0.0, 1.0) var ThrottleIdle:float = 0.25
## Timing on RPM.
## Set this beyond the rev range to disable it, set it to 0 to use this vvt state permanently.
@export var VVTRPM:float = 4500.0 

@export_group("Torque normal state")
@export var torque_norm:ViVeCarTorque = ViVeCarTorque.new()

@export_group("Torque")
@export var torque_vvt:ViVeCarTorque = ViVeCarTorque.new("VVT")

@export_group("Clutch")
## Fix for engine's responses to friction. Higher values would make it sluggish.
@export var ClutchStable:float = 0.5
## Usually on a really short gear, the engine would jitter. This fixes it to say the least.
@export var GearRatioRatioThreshold:float = 200.0
## Fix correlated to GearRatioRatioThreshold. Keep this value as it is.
@export var ThresholdStable:float = 0.01
## Clutch Capacity (nm).
@export var ClutchGrip:float = 176.125
## Prevents RPM "Floating". This gives a better sensation on accelerating. 
## Setting it too high would reverse the "floating". Setting it to 0 would turn it off.
@export var ClutchFloatReduction:float = 27.0

@export var ClutchWobble:float = 2.5 * 0

@export var ClutchElasticity:float = 0.2 * 0

@export var WobbleRate:float = 0.0

@export_group("Forced Inductions")
## Maximum air generated by any forced inductions.
@export var MaxPSI:float = 9.0
## Compression ratio has an effect on forced induction systems. 
##This is only an information for VitaVehicle to read boosts and it doesn't affect torque when TurboEnabled is off.
@export var EngineCompressionRatio:float = 8.0 # Piston travel distance

@export_group("Turbo")
## Turbocharger. Enables turbo.
@export var TurboEnabled:bool = false
## Amount of turbochargers, multiplies boost power.
@export var TurboAmount:float = 1.0
## Turbo Lag. Higher = More turbo lag.
@export var TurboSize:float = 8.0
## Counters TurboSize. Higher = Allows more spooling on low RPM.
@export var Compressor:float = 0.3
## Threshold of throttle before spooling.
@export_range(0.0, 0.9999) var SpoolThreshold:float = 0.1
## How instant spooling stops.
@export var BlowoffRate:float = 0.14
## Turbo Response.
@export_range(0.0, 1.0) var TurboEfficiency:float = 0.075
## Allowing Negative PSI. Performance deficiency upon turbo idle.
@export var TurboVacuum:float = 1.0 

@export_group("Supercharger")
## Enables supercharger.
@export var SuperchargerEnabled:bool = false 
## Boost applied upon engine speeds.
@export var SCRPMInfluence:float = 1.0
## Boost Amplification.
@export var BlowRate:float = 35.0
## Deadzone before boost.
@export var SCThreshold:float = 6.0

var _rpm:float = 0.0
var _rpmspeed:float = 0.0
var _resistancerpm:float = 0.0
var _resistancedv:float = 0.0

var _limdel:float = 0.0
var _actualgear:int = 0
var _gearstress:float = 0.0
var _throttle:float = 0.0
var _cvtaccel:float = 0.0
var _sassistdel:float = 0.0
var _sassiststep:int = 0
var _clutchpedalreal:float = 0.0
var _abspump:float = 0.0
var _tcsweight:float = 0.0
var _tcsflash:bool = false
var _espflash:bool = false
var _ratio:float = 0.0
var _vvt:bool = false
var _brake_allowed:float = 0.0
var _readout_torque:float = 0.0

var _brakeline:float = 0.0
var _dsweight:float = 0.0
var _dsweightrun:float = 0.0
var _diffspeed:float = 0.0
var _diffspeedun:float = 0.0
var _locked:float = 0.0
var _c_locked:float = 0.0
var _wv_difference:float = 0.0
var _rpmforce:float = 0.0
var _whinepitch:float = 0.0
var _turbopsi:float = 0.0
var _scrpm:float = 0.0
var _boosting:float = 0.0
var _rpmcs:float = 0.0
var _rpmcsm:float = 0.0
var _currentstable:float = 0.0
var _steering_geometry:Array[float] = [0.0,0.0] #0 is x, 1 is z?
var _resistance:float = 0.0
var _wob:float = 0.0
var _ds_weight:float = 0.0
var _steer_torque:float = 0.0

var _drivewheels_size:float = 1.0

var _steering_angles:Array[float] = []
var _max_steering_angle:float = 0.0


var _pastvelocity:Vector3 = Vector3(0,0,0)
var _gforce:Vector3 = Vector3(0,0,0)
var _clock_mult:float = 1.0
var _dist:float = 0.0
var _stress:float = 0.0

var _velocity:Vector3 = Vector3(0,0,0)
var _rvelocity:Vector3 = Vector3(0,0,0)

var _stalled:float = 0.0

func bullet_fix() -> void:
	var offset:Vector3 = drag_center.position
	AckermannPoint -= offset.z
	
	for i:Node3D in get_children():
		i.position -= offset

## Emitted when the wheels are ready.
signal wheels_ready

func _ready() -> void:
#	bullet_fix()
	_control_func = decide_controls()
	_rpm = IdleRPM
	for i:String in Powered_Wheels:
		var wh:ViVeWheel = get_node(str(i))
		c_pws.append(wh)
	var _err:Error = emit_signal("wheels_ready")

##Get the wheels of the car.
func get_wheels() -> Array[ViVeWheel]:
	return [front_left, front_right, back_left, back_right]

##Get the powered wheels of the car.
func get_powered_wheels() -> Array[ViVeWheel]:
	var return_this:Array[ViVeWheel] = []
	for wheels:String in Powered_Wheels:
		return_this.append(get_node(wheels))
	return return_this

func _mouse_wrapper() -> void:
	var mouseposx:float = 0.0
	mouseposx = get_window().get_mouse_position().x / get_window().size.x
	car_controls.controls_keyboard_mouse(mouseposx)

##Check which [Callable] from [ViVeCarControls] to use for the car's controls.
func decide_controls() -> Callable:
	ViVeTouchControls.singleton.visible = false
	match car_controls.control_type as ViVeCarControls.ControlType:
		ViVeCarControls.ControlType.CONTROLS_KEYBOARD_MOUSE:
			return _mouse_wrapper
		ViVeCarControls.ControlType.CONTROLS_TOUCH:
			ViVeTouchControls.singleton.show()
			return car_controls.controls_touchscreen
		ViVeCarControls.ControlType.CONTROLS_JOYPAD:
			return car_controls.controls_joypad
	return _mouse_wrapper

func new_controls() -> void:
	if car_controls.control_type != car_controls_cache:
		_control_func = decide_controls()
		car_controls_cache = car_controls.control_type as ViVeCarControls.ControlType
	_control_func.call()

func controls() -> void:
	#Tbh I don't see why these need to be divided, but...
	if car_controls.UseMouseSteering:
		car_controls.gas = Input.is_action_pressed("gas_mouse")
		car_controls.brake = Input.is_action_pressed("brake_mouse")
		car_controls.su = Input.is_action_just_pressed("shiftup_mouse")
		car_controls.sd = Input.is_action_just_pressed("shiftdown_mouse")
		car_controls.handbrake = Input.is_action_pressed("handbrake_mouse")
	else:
		car_controls.gas = Input.is_action_pressed("gas")
		car_controls.brake = Input.is_action_pressed("brake")
		car_controls.su = Input.is_action_just_pressed("shiftup")
		car_controls.sd = Input.is_action_just_pressed("shiftdown")
		car_controls.handbrake = Input.is_action_pressed("handbrake")
	
	car_controls.left = Input.is_action_pressed("left")
	car_controls.right = Input.is_action_pressed("right")
	
	if car_controls.left:
		car_controls.steer_velocity -= 0.01
	elif car_controls.right:
		car_controls.steer_velocity += 0.01
	
	if car_controls.LooseSteering:
		car_controls.steer += car_controls.steer_velocity
		
		if abs(car_controls.steer) > 1.0:
			car_controls.steer_velocity *= -0.5
		
		for i:ViVeWheel in [front_left,front_right]:
			car_controls.steer_velocity += (i.directional_force.x * 0.00125) * i.Caster
			car_controls.steer_velocity -= (i.stress * 0.0025) * (atan2(absf(i.wv), 1.0) * i.angle)
			
			car_controls.steer_velocity += car_controls.steer * (i.directional_force.z * 0.0005) * i.Caster
			
			if i.position.x > 0:
				car_controls.steer_velocity += i.directional_force.z * 0.0001
			else:
				car_controls.steer_velocity -= i.directional_force.z * 0.0001
		
			car_controls.steer_velocity /= i.stress / (i.slip_percpre * (i.slip_percpre * 100.0) + 1.0) + 1.0
	
	if Controlled:
		if GearAssist.assist_level == 2:
			if (car_controls.gas and not car_controls.gasrestricted and not car_controls.gear == -1) or (car_controls.brake and car_controls.gear == -1) or car_controls.revmatch:
				car_controls.gaspedal += car_controls.OnThrottleRate / _clock_mult
			else:
				car_controls.gaspedal -= car_controls.OffThrottleRate / _clock_mult
			if (car_controls.brake and not car_controls.gear == -1) or (car_controls.gas and car_controls.gear == -1):
				car_controls.brakepedal += car_controls.OnBrakeRate / _clock_mult
			else:
				car_controls.brakepedal -= car_controls.OffBrakeRate / _clock_mult
		else:
			if GearAssist.assist_level == 0:
				car_controls.gasrestricted = false
				car_controls.clutchin = false
				car_controls.revmatch = false
			
			if car_controls.gas and not car_controls.gasrestricted or car_controls.revmatch:
				car_controls.gaspedal += car_controls.OnThrottleRate / _clock_mult
			else:
				car_controls.gaspedal -= car_controls.OffThrottleRate / _clock_mult
			
			if car_controls.brake:
				car_controls.brakepedal += car_controls.OnBrakeRate / _clock_mult
			else:
				car_controls.brakepedal -= car_controls.OffBrakeRate / _clock_mult
		
		if car_controls.handbrake:
			car_controls.handbrakepull += car_controls.OnHandbrakeRate / _clock_mult
		else:
			car_controls.handbrakepull -= car_controls.OffHandbrakeRate / _clock_mult
		
		var siding:float = absf(_velocity.x)
		
		#Based on the syntax, I'm unsure if this is doing what it "should" do...?
		if (_velocity.x > 0 and car_controls.steer2 > 0) or (_velocity.x < 0 and car_controls.steer2 < 0):
			siding = 0.0
		
		var going:float = _velocity.z / (siding + 1.0)
		going = maxf(going, 0)
		
		#Steer based on control options
		if not car_controls.LooseSteering:
			
			if car_controls.UseMouseSteering:
				var mouseposx:float = 0.0
#				if get_viewport().size.x > 0.0:
#					mouseposx = get_viewport().get_mouse_position().x / get_viewport().size.x
				if get_window().size.x > 0.0:
					mouseposx = get_window().get_mouse_position().x / get_window().size.x
				
				car_controls.steer2 = (mouseposx - 0.5) * 2.0
				car_controls.steer2 *= car_controls.SteerSensitivity
				
				car_controls.steer2 = clampf(car_controls.steer2, -1.0, 1.0)
				
				var s:float = abs(car_controls.steer2) * 1.0 + 0.5
				s = minf(s, 1.0)
				
				car_controls.steer2 *= s
				mouseposx = (mouseposx - 0.5) * 2.0
				#steer2 = control_steer_analog(mouseposx)
				
				#steer2 = control_steer_analog(Input.get_joy_axis(0, JOY_AXIS_LEFT_X))
				
			elif car_controls.UseAccelerometreSteering:
				car_controls.steer2 = Input.get_accelerometer().x / 10.0
				car_controls.steer2 *= car_controls.SteerSensitivity
				
				car_controls.steer2 = clampf(car_controls.steer2, -1.0, 1.0)
				
				var s:float = abs(car_controls.steer2) * 1.0 +0.5
				s = minf(s, 1.0)
				
				car_controls.steer2 *= s
			else:
				if car_controls.right:
					if car_controls.steer2 > 0:
						car_controls.steer2 += car_controls.KeyboardSteerSpeed
					else:
						car_controls.steer2 += car_controls.KeyboardCompensateSpeed
				elif car_controls.left:
					if car_controls.steer2 < 0:
						car_controls.steer2 -= car_controls.KeyboardSteerSpeed
					else:
						car_controls.steer2 -= car_controls.KeyboardCompensateSpeed
				else:
					if car_controls.steer2 > car_controls.KeyboardReturnSpeed:
						car_controls.steer2 -= car_controls.KeyboardReturnSpeed
					elif car_controls.steer2 < - car_controls.KeyboardReturnSpeed:
						car_controls.steer2 += car_controls.KeyboardReturnSpeed
					else:
						car_controls.steer2 = 0.0
				car_controls.steer2 = clampf(car_controls.steer2, -1.0, 1.0)
			
			
			if car_controls.assistance_factor > 0.0:
				var maxsteer:float = 1.0 / (going * (car_controls.SteerAmountDecay / car_controls.assistance_factor) + 1.0)
				
				var assist_commence:float = linear_velocity.length() / 10.0
				assist_commence = minf(assist_commence, 1.0)
				
				car_controls.steer = (car_controls.steer2 * maxsteer) - (_velocity.normalized().x * assist_commence) * (car_controls.SteeringAssistance * car_controls.assistance_factor) + _rvelocity.y * (car_controls.SteeringAssistanceAngular * car_controls.assistance_factor)
			else:
				car_controls.steer = car_controls.steer2

func limits() -> void:
	car_controls.gaspedal = clampf(car_controls.gaspedal, 0.0, car_controls.MaxThrottle)
	car_controls.brakepedal = clampf(car_controls.brakepedal, 0.0, car_controls.MaxBrake)
	car_controls.handbrakepull = clampf(car_controls.handbrakepull, 0.0, car_controls.MaxHandbrake)
	car_controls.steer = clampf(car_controls.steer, -1.0, 1.0)

func transmission() -> void:
	car_controls.su = (Input.is_action_just_pressed("shiftup") and not car_controls.UseMouseSteering) or (Input.is_action_just_pressed("shiftup_mouse") and car_controls.UseMouseSteering)
	car_controls.sd = (Input.is_action_just_pressed("shiftdown") and not car_controls.UseMouseSteering) or (Input.is_action_just_pressed("shiftdown_mouse") and car_controls.UseMouseSteering)
	
	#var clutch:bool
	car_controls.clutch = Input.is_action_pressed("clutch") and not car_controls.UseMouseSteering or Input.is_action_pressed("clutch_mouse") and car_controls.UseMouseSteering
	if not GearAssist.assist_level == 0:
		car_controls.clutch = Input.is_action_pressed("handbrake") and not car_controls.UseMouseSteering or Input.is_action_pressed("handbrake_mouse") and car_controls.UseMouseSteering
	car_controls.clutch = not car_controls.clutch
	
	if TransmissionType == 0:
		if car_controls.clutch and not car_controls.clutchin:
			_clutchpedalreal -= car_controls.OffClutchRate / _clock_mult
		else:
			_clutchpedalreal += car_controls.OnClutchRate / _clock_mult
		
		_clutchpedalreal = clamp(_clutchpedalreal, 0, car_controls.MaxClutch)
		
		car_controls.clutchpedal = 1.0 - _clutchpedalreal
		
		if car_controls.gear > 0:
			_ratio = GearRatios[car_controls.gear - 1] * FinalDriveRatio * RatioMult
		elif car_controls.gear == -1:
			_ratio = ReverseRatio * FinalDriveRatio * RatioMult
		if GearAssist.assist_level == 0:
			if car_controls.su:
				car_controls.su = false
				if car_controls.gear < len(GearRatios):
					if _gearstress < GearGap:
						_actualgear += 1
			if car_controls.sd:
				car_controls.sd = false
				if car_controls.gear > -1:
					if _gearstress < GearGap:
						_actualgear -= 1
		elif GearAssist.assist_level == 1:
			if _rpm < GearAssist.clutch_out_RPM:
				var irga_ca:float = (GearAssist.clutch_out_RPM - _rpm) / (GearAssist.clutch_out_RPM - IdleRPM)
				_clutchpedalreal = pow(irga_ca, 2)
				_clutchpedalreal = minf(1.0, _clutchpedalreal)
			else:
				if not car_controls.gasrestricted and not car_controls.revmatch:
					car_controls.clutchin = false
			if car_controls.su:
				car_controls.su = false
				if car_controls.gear < len(GearRatios):
					if _rpm < GearAssist.clutch_out_RPM:
						_actualgear += 1
					else:
						if _actualgear < 1:
							_actualgear += 1
							if _rpm > GearAssist.clutch_out_RPM:
								car_controls.clutchin = false
						else:
							if _sassistdel > 0:
								_actualgear += 1
							_sassistdel = GearAssist.shift_delay / 2.0
							_sassiststep = -4
							
							car_controls.clutchin = true
							car_controls.gasrestricted = true
			elif car_controls.sd:
				car_controls.sd = false
				if car_controls.gear > -1:
					if _rpm < GearAssist.clutch_out_RPM:
						_actualgear -= 1
					else:
						if _actualgear == 0 or _actualgear == 1:
							_actualgear -= 1
							car_controls.clutchin = false
						else:
							if _sassistdel > 0:
								_actualgear -= 1
							_sassistdel = GearAssist.shift_delay / 2.0
							_sassiststep = -2
							
							car_controls.clutchin = true
							car_controls.revmatch = true
							car_controls.gasrestricted = false
		elif GearAssist.assist_level == 2:
			var assistshiftspeed:float = (GearAssist.upshift_RPM / _ratio) * GearAssist.speed_influence
			var assistdownshiftspeed:float = (GearAssist.down_RPM / abs((GearRatios[car_controls.gear - 2] * FinalDriveRatio) * RatioMult)) * GearAssist.speed_influence
			if car_controls.gear == 0:
				if car_controls.gas:
					_sassistdel -= 1
					if _sassistdel < 0:
						_actualgear = 1
				elif car_controls.brake:
					_sassistdel -= 1
					if _sassistdel < 0:
						_actualgear = -1
				else:
					_sassistdel = 60
			elif linear_velocity.length() < 5:
				if not car_controls.gas and car_controls.gear == 1 or not car_controls.brake and car_controls.gear == -1:
					_sassistdel = 60
					_actualgear = 0
			if _sassiststep == 0:
				if _rpm < GearAssist.clutch_out_RPM:
					var irga_ca:float = (GearAssist.clutch_out_RPM - _rpm) / (GearAssist.clutch_out_RPM - IdleRPM)
					_clutchpedalreal = irga_ca * irga_ca
					_clutchpedalreal = minf(_clutchpedalreal, 1.0)
					
				else:
					car_controls.clutchin = false
				if not car_controls.gear == -1:
					if car_controls.gear < len(GearRatios) and linear_velocity.length() > assistshiftspeed:
						_sassistdel = GearAssist.shift_delay / 2.0
						_sassiststep = -4
						
						car_controls.clutchin = true
						car_controls.gasrestricted = true
					if car_controls.gear > 1 and linear_velocity.length() < assistdownshiftspeed:
						_sassistdel = GearAssist.shift_delay / 2.0
						_sassiststep = -2
						
						car_controls.clutchin = true
						car_controls.gasrestricted = false
						car_controls.revmatch = true
		
		if _sassiststep == -4 and _sassistdel < 0:
			_sassistdel = GearAssist.shift_delay / 2.0
			if car_controls.gear < len(GearRatios):
				_actualgear += 1
			_sassiststep = -3
		elif _sassiststep == -3 and _sassistdel < 0:
			if _rpm > GearAssist.clutch_out_RPM:
				car_controls.clutchin = false
			if _sassistdel < - GearAssist.input_delay:
				_sassiststep = 0
				car_controls.gasrestricted = false
		elif _sassiststep == -2 and _sassistdel < 0:
			_sassiststep = 0
			if car_controls.gear > -1:
				_actualgear -= 1
			if _rpm > GearAssist.clutch_out_RPM:
				car_controls.clutchin = false
			car_controls.gasrestricted = false
			car_controls.revmatch = false
		car_controls.gear = _actualgear
	
	elif TransmissionType == 1:
		car_controls.clutchpedal = (_rpm - float(AutoSettings.AutoSettings.engage_rpm_thresh) * (car_controls.gaspedal * float(AutoSettings.throt_eff_thresh) + (1.0 - float(AutoSettings.throt_eff_thresh))) ) / float(AutoSettings.engage_rpm)
		
		if not GearAssist.assist_level == 2:
			if car_controls.su:
				car_controls.su = false
				if car_controls.gear < 1:
					_actualgear += 1
			if car_controls.sd:
				car_controls.sd = false
				if car_controls.gear > -1:
					_actualgear -= 1
		else:
			if car_controls.gear == 0:
				if car_controls.gas:
					_sassistdel -= 1
					if _sassistdel < 0:
						_actualgear = 1
				elif car_controls.brake:
					_sassistdel -= 1
					if _sassistdel < 0:
						_actualgear = -1
				else:
					_sassistdel = 60
			elif linear_velocity.length()<5:
				if not car_controls.gas and car_controls.gear == 1 or not car_controls.brake and car_controls.gear == -1:
					_sassistdel = 60
					_actualgear = 0
				
		if _actualgear == -1:
			_ratio = ReverseRatio * FinalDriveRatio * RatioMult
		else:
			_ratio = GearRatios[car_controls.gear - 1] * FinalDriveRatio * RatioMult
		if _actualgear > 0:
			var lastratio:float = GearRatios[car_controls.gear - 2] * FinalDriveRatio * RatioMult
			car_controls.su = false
			car_controls.sd = false
			for i:ViVeWheel in c_pws:
				if (i.wv / GearAssist.speed_influence) > (float(AutoSettings.shift_rpm) * (car_controls.gaspedal *float(AutoSettings.throt_eff_thresh) + (1.0 - float(AutoSettings.throt_eff_thresh)))) / _ratio:
					car_controls.su = true
				elif (i.wv / GearAssist.speed_influence) < ((float(AutoSettings.shift_rpm) - float(AutoSettings.downshift_thresh)) * (car_controls.gaspedal * float(AutoSettings.throt_eff_thresh) + (1.0 - float(AutoSettings.throt_eff_thresh)))) / lastratio:
					car_controls.sd = true
					
			if car_controls.su:
				car_controls.gear += 1
			elif car_controls.sd:
				car_controls.gear -= 1
			
			car_controls.gear = clampi(car_controls.gear, 1, len(GearRatios))
			
		else:
			car_controls.gear = _actualgear
	elif TransmissionType == 2:
		
		car_controls.clutchpedal = (_rpm - float(AutoSettings.engage_rpm_thresh) * (car_controls.gaspedal * float(AutoSettings.throt_eff_thresh) + (1.0 - float(AutoSettings.throt_eff_thresh))) ) / float(AutoSettings.engage_rpm)
		
			#clutchpedal = 1
		
		if not GearAssist.assist_level == 2:
			if car_controls.su:
				car_controls.su = false
				if car_controls.gear < 1:
					_actualgear += 1
			if car_controls.sd:
				car_controls.sd = false
				if car_controls.gear > -1:
					_actualgear -= 1
		else:
			if car_controls.gear == 0:
				if car_controls.gas:
					_sassistdel -= 1
					if _sassistdel < 0:
						_actualgear = 1
				elif car_controls.brake:
					_sassistdel -= 1
					if _sassistdel < 0:
						_actualgear = -1
				else:
					_sassistdel = 60
			elif linear_velocity.length() < 5:
				if not car_controls.gas and car_controls.gear == 1 or not car_controls.brake and car_controls.gear == -1:
					_sassistdel = 60
					_actualgear = 0
		
		car_controls.gear = _actualgear
		var wv:float = 0.0
		
		for i:ViVeWheel in c_pws:
			wv += i.wv / len(c_pws)
		
		_cvtaccel -= (_cvtaccel - (car_controls.gaspedal * CVTSettings.throt_eff_thresh + (1.0 - CVTSettings.throt_eff_thresh))) * CVTSettings.accel_rate
		
		var a:float = CVTSettings.iteration_3 / ((abs(wv) / 10.0) * _cvtaccel + 1.0)
		
		a = maxf(a, CVTSettings.iteration_4)
		
		_ratio = (CVTSettings.iteration_1 * 10000000.0) / (abs(wv) * (_rpm * a) + 1.0)
		
		
		_ratio = minf(_ratio, CVTSettings.iteration_2)
	
	elif TransmissionType == 3:
		car_controls.clutchpedal = (_rpm - float(AutoSettings.engage_rpm_thresh) * (car_controls.gaspedal * float(AutoSettings.throt_eff_thresh) + (1.0 - float(AutoSettings.throt_eff_thresh))) ) /float(AutoSettings.engage_rpm)
		
		if car_controls.gear > 0:
			_ratio = GearRatios[car_controls.gear - 1] * FinalDriveRatio * RatioMult
		elif car_controls.gear == -1:
			_ratio = ReverseRatio * FinalDriveRatio * RatioMult
		
		if GearAssist.assist_level < 2:
			if car_controls.su:
				car_controls.su = false
				if car_controls.gear < len(GearRatios):
					_actualgear += 1
			if car_controls.sd:
				car_controls.sd = false
				if car_controls.gear > -1:
					_actualgear -= 1
		else:
			var assistshiftspeed:float = (GearAssist.upshift_RPM / _ratio) * GearAssist.speed_influence
			var assistdownshiftspeed:float = (GearAssist.down_RPM / abs((GearRatios[car_controls.gear - 2] * FinalDriveRatio) * RatioMult)) * GearAssist.speed_influence
			if car_controls.gear == 0:
				if car_controls.gas:
					_sassistdel -= 1
					if _sassistdel < 0:
						_actualgear = 1
				elif car_controls.brake:
					_sassistdel -= 1
					if _sassistdel < 0:
						_actualgear = -1
				else:
					_sassistdel = 60
			elif linear_velocity.length()<5:
				if not car_controls.gas and car_controls.gear == 1 or not car_controls.brake and car_controls.gear == -1:
					_sassistdel = 60
					_actualgear = 0
			if _sassiststep == 0:
				if not car_controls.gear == -1:
					if car_controls.gear < len(GearRatios) and linear_velocity.length() > assistshiftspeed:
						_actualgear += 1
					if car_controls.gear > 1 and linear_velocity.length() < assistdownshiftspeed:
						_actualgear -= 1
		
		car_controls.gear = _actualgear
	
	car_controls.clutchpedal = clampf(car_controls.clutchpedal, 0.0, 1.0)

func drivetrain() -> void:
	
		_rpmcsm -= (_rpmcs - _resistance)
	
		_rpmcs += _rpmcsm * ClutchElasticity
		
		_rpmcs -= _rpmcs * (1.0 - car_controls.clutchpedal)
		
		_wob = ClutchWobble * car_controls.clutchpedal
		
		_wob *= _ratio * WobbleRate
		
		_rpmcs -= (_rpmcs - _resistance) * (1.0 / (_wob + 1.0))
		
		#torquereadout = multivariate(RiseRPM,TorqueRise,BuildUpTorque,EngineFriction,EngineDrag,OffsetTorque,_rpm,DeclineRPM,DeclineRate,FloatRate,turbopsi,TurboAmount,EngineCompressionRatio,TurboEnabled,VVTRPM,VVT_BuildUpTorque,VVT_TorqueRise,VVT_RiseRPM,VVT_OffsetTorque,VVT_FloatRate,VVT_DeclineRPM,VVT_DeclineRate,SuperchargerEnabled,SCRPMInfluence,BlowRate,SCThreshold)
		if car_controls.gear < 0:
			_rpm -= ((_rpmcs * 1.0) / _clock_mult) * (RevSpeed / 1.475)
		else:
			_rpm += ((_rpmcs * 1.0) / _clock_mult) * (RevSpeed / 1.475)
		
		if "": #...what-
			_rpm = 7000.0
			Locking = 0.0
			CoastLocking = 0.0
			Centre_Locking = 0.0
			Centre_CoastLocking = 0.0
			Preload = 1.0
			Centre_Preload = 1.0
			ClutchFloatReduction = 0.0
		
		_gearstress = (abs(_resistance) * StressFactor) * car_controls.clutchpedal
		var stabled:float = _ratio * 0.9 + 0.1
		_ds_weight = DSWeight / stabled
		
		_whinepitch = abs(_rpm / _ratio) * 1.5
		
		if _resistance > 0.0:
			_locked = abs(_resistance / _ds_weight) * (CoastLocking / 100.0) + Preload
		else:
			_locked = abs(_resistance / _ds_weight) * (Locking / 100.0) + Preload
		
		_locked = clampf(_locked, 0.0, 1.0)
		
		if _wv_difference > 0.0:
			_c_locked = abs(_wv_difference) * (Centre_CoastLocking / 10.0) + Centre_Preload
		else:
			_c_locked = abs(_wv_difference) * (Centre_Locking / 10.0) + Centre_Preload
		if _c_locked < 0.0 or len(c_pws) < 4:
			_c_locked = 0.0
		elif _c_locked > 1.0:
			_c_locked = 1.0
		#_c_locked = minf(_c_locked, 1.0)
		
		var maxd:ViVeWheel = VitaVehicleSimulation.fastest_wheel(c_pws)
		#var mind:ViVeWheel = VitaVehicleSimulation.slowest_wheel(c_pws)
		var what:float = 0.0
		
		var floatreduction:float = ClutchFloatReduction
		
		if _dsweightrun > 0.0:
			floatreduction = ClutchFloatReduction / _dsweightrun
		else:
			floatreduction = 0.0
		
		var stabling:float = - (GearRatioRatioThreshold - _ratio * _drivewheels_size) * ThresholdStable
		stabling = maxf(stabling, 0.0)
		
		_currentstable = ClutchStable + stabling
		_currentstable *= (RevSpeed / 1.475)
		
		if _dsweightrun > 0.0:
			what = (_rpm -(((_rpmforce * floatreduction) * pow(_currentstable, 1.0)) / (_ds_weight / _dsweightrun)))
		else:
			what = _rpm
			
		if car_controls.gear < 0.0:
			_dist = maxd.wv + what / _ratio
		else:
			_dist = maxd.wv - what / _ratio
		
		_dist *= (car_controls.clutchpedal * car_controls.clutchpedal)
		
		if car_controls.gear == 0:
			_dist *= 0.0
		
		_wv_difference = 0.0
		_drivewheels_size = 0.0
		for i:ViVeWheel in c_pws:
			_drivewheels_size += i.w_size / len(c_pws)
			i.c_p = i.W_PowerBias
			_wv_difference += ((i.wv - what / _ratio) / (len(c_pws))) * (car_controls.clutchpedal * car_controls.clutchpedal)
			if car_controls.gear < 0:
				i.dist = _dist * (1 - _c_locked) + (i.wv + what / _ratio) * _c_locked
			else:
				i.dist = _dist * (1 - _c_locked) + (i.wv - what / _ratio) * _c_locked
			if car_controls.gear == 0:
				i.dist *= 0.0
		GearAssist.speed_influence = _drivewheels_size
		_resistance = 0.0
		_dsweightrun = _dsweight
		_dsweight = 0.0
		_tcsweight = 0.0
		_stress = 0.0

func aero() -> void:
	var drag:float = DragCoefficient
	#var df:float = Downforce
	
#	var veloc = global_transform.basis.orthonormalized().xform_inv(linear_velocity)
	var veloc:Vector3 = global_transform.basis.orthonormalized().transposed() * (linear_velocity)
	
#	var torq = global_transform.basis.orthonormalized().xform_inv(Vector3(1,0,0))
	#var torq = global_transform.basis.orthonormalized().transposed() * (Vector3(1,0,0))
	
#	apply_torque_impulse(global_transform.basis.orthonormalized().xform( Vector3(((-veloc.length()*0.3)*LiftAngle),0,0)  ) )
	apply_torque_impulse(global_transform.basis.orthonormalized() * ( Vector3(((-veloc.length() * 0.3) * LiftAngle), 0, 0) ) )
	
	var vx:float = veloc.x * 0.15
	var vy:float = veloc.z * 0.15
	var vz:float = veloc.y * 0.15
	var vl:float = veloc.length() * 0.15
	
#	var forc = global_transform.basis.orthonormalized().xform(Vector3(1,0,0))*(-vx*drag)
	var forc:Vector3 = global_transform.basis.orthonormalized() * (Vector3(1, 0, 0)) * (- vx * drag)
#	forc += global_transform.basis.orthonormalized().xform(Vector3(0,0,1))*(-vy*drag)
	forc += global_transform.basis.orthonormalized() * (Vector3(0, 0, 1)) * (- vy * drag)
#	forc += global_transform.basis.orthonormalized().xform(Vector3(0,1,0))*(-vl*df -vz*drag)
	forc += global_transform.basis.orthonormalized() * (Vector3(0, 1, 0)) * (- vl * Downforce - vz * drag)
	
	if has_node("DRAG_CENTRE"):
#		apply_impulse(global_transform.basis.orthonormalized().xform($DRAG_CENTRE.position),forc)
		apply_impulse(forc, global_transform.basis.orthonormalized() * (drag_center.position))
	else:
		apply_central_impulse(forc)

func _physics_process(_delta:float) -> void:
	
	if len(_steering_angles) > 0:
		_max_steering_angle = 0.0
		for i:float in _steering_angles:
			_max_steering_angle = maxf(_max_steering_angle,i)
		
		car_controls.assistance_factor = 90.0 / _max_steering_angle
	_steering_angles = []
	
	#TODO: Set these elsewhere, such as a settings file
	if car_controls.Use_Global_Control_Settings:
		car_controls = VitaVehicleSimulation.universal_controls
		
		GearAssist.assist_level = VitaVehicleSimulation.GearAssistant
	
#	velocity = global_transform.basis.orthonormalized().xform_inv(linear_velocity)
	_velocity = global_transform.basis.orthonormalized().transposed() * (linear_velocity)
#	rvelocity = global_transform.basis.orthonormalized().xform_inv(angular_velocity)
	_rvelocity = global_transform.basis.orthonormalized().transposed() * (angular_velocity)
	
	#if not mass == Weight / 10.0:
	#	mass = Weight/10.0
	mass = Weight / 10.0
	aero()
	
	_gforce = (linear_velocity - _pastvelocity) * ((0.30592 / 9.806) * 60.0)
	_pastvelocity = linear_velocity
	
#	_gforce = global_transform.basis.orthonormalized().xform_inv(_gforce)
	_gforce = global_transform.basis.orthonormalized().transposed() * (_gforce)
	
	car_controls.front_left = front_left
	car_controls.front_right = front_right
	car_controls.velocity = _velocity
	car_controls.rvelocity = _rvelocity
	car_controls.linear_velocity = linear_velocity
	car_controls.GearAssist = GearAssist
	new_controls()
	#controls()
	
	_ratio = 10.0
	
	_sassistdel -= 1
	
	transmission()
	
	car_controls.gaspedal = clampf(car_controls.gaspedal, 0.0, car_controls.MaxThrottle)
	car_controls.brakepedal = clampf(car_controls.brakepedal, 0.0, car_controls.MaxBrake)
	car_controls.handbrakepull = clampf(car_controls.handbrakepull, 0.0, car_controls.MaxHandbrake)
	car_controls.steer = clampf(car_controls.steer, -1.0, 1.0)
	
	var steeroutput:float = car_controls.steer
	
	var uhh:float = pow((_max_steering_angle / 90.0), 2)
	uhh *= 0.5
	steeroutput *= abs(car_controls.steer) * (uhh) + (1.0 - uhh)
	
	if abs(steeroutput) > 0.0:
		_steering_geometry = [ 
			- Steer_Radius / steeroutput, 
			AckermannPoint
		]
		#steering_geometry[0] = (- Steer_Radius / steeroutput)
		#steering_geometry[1] = AckermannPoint
	
	_abspump -= 1    
	
	if _abspump < 0:
		_brake_allowed += ABS.pump_force
	else:
		_brake_allowed -= ABS.pump_force
	
	_brake_allowed = clampf(_brake_allowed, 0.0, 1.0)
	
	_brakeline = car_controls.brakepedal * _brake_allowed
	
	_brakeline = maxf(_brakeline, 0.0)
	
	_limdel -= 1
	
	if _limdel < 0:
		_throttle -= (_throttle - (car_controls.gaspedal / (_tcsweight * car_controls.clutchpedal + 1.0))) * (ThrottleResponse / _clock_mult)
	else:
		_throttle -= _throttle * (ThrottleResponse / _clock_mult)
	
	if _rpm > RPMLimit:
		if _throttle > ThrottleLimit:
			_throttle = ThrottleLimit
			_limdel = LimiterDelay
	elif _rpm < IdleRPM:
		_throttle = maxf(_throttle, ThrottleIdle)
	
	#var stab:float = 300.0
	var thr:float = 0.0
	
	if TurboEnabled:
		thr = (_throttle - SpoolThreshold) / (1 - SpoolThreshold)
		
		if _boosting > thr:
			_boosting = thr
		else:
			_boosting -= (_boosting - thr) * TurboEfficiency
		 
		_turbopsi += (_boosting * _rpm) / ((TurboSize / Compressor) * 60.9)
		
		_turbopsi -= _turbopsi * BlowoffRate
		
		_turbopsi = minf(_turbopsi, MaxPSI)
		
		_turbopsi = maxf(_turbopsi, -TurboVacuum)
	
	elif SuperchargerEnabled:
		_scrpm = _rpm * SCRPMInfluence
		_turbopsi = (_scrpm / 10000.0) * BlowRate - SCThreshold
		
		_turbopsi = clampf(_turbopsi, 0.0, MaxPSI)
	
	else:
		_turbopsi = 0.0
	
	_vvt = _rpm > VVTRPM
	
	var torque:float = 0.0
	
	var torque_local:ViVeCarTorque
	if _vvt:
		torque_local = torque_vvt
	else:
		torque_local = torque_norm
	
	var f:float = _rpm - torque_local.RiseRPM
	f = maxf(f, 0.0)
	
	torque = (_rpm * torque_local.BuildUpTorque + torque_local.OffsetTorque + (f * f) * (torque_local.TorqueRise / 10000000.0)) * _throttle
	torque += ( (_turbopsi * TurboAmount) * (EngineCompressionRatio * 0.609) )
	
	var j:float = _rpm - torque_local.DeclineRPM
	j = maxf(j, 0.0)
	
	torque /= (j * (j * torque_local.DeclineSharpness + (1.0 - torque_local.DeclineSharpness))) * (torque_local.DeclineRate / 10000000.0) + 1.0
	torque /= abs(_rpm * abs(_rpm)) * (torque_local.FloatRate / 10000000.0) + 1.0
	
	_rpmforce = (_rpm / (abs(_rpm * abs(_rpm)) / (EngineFriction / _clock_mult) + 1.0)) * 1.0
	if _rpm < DeadRPM:
		torque = 0.0
		_rpmforce /= 5.0
		_stalled = 1.0 - _rpm / DeadRPM
	else:
		_stalled = 0.0
	
	_rpmforce += (_rpm * (EngineDrag / _clock_mult)) * 1.0
	_rpmforce -= (torque / _clock_mult) * 1.0
	_rpm -= _rpmforce * RevSpeed
	
	drivetrain()


var front_load:float = 0.0
var total:float = 0.0

var weight_dist:Array[float] = [0.0,0.0]

func _process(_delta:float) -> void:
	if Debug_Mode:
		front_wheels = []
		rear_wheels = []
		#Why is this run?
		for i:ViVeWheel in get_wheels():
			if i.position.z > 0:
				front_wheels.append(i)
			else:
				rear_wheels.append(i)
		
		front_load = 0.0
		total = 0.0
		
		for f:ViVeWheel in front_wheels:
			front_load += f.directional_force.y
			total += f.directional_force.y
		for r:ViVeWheel in rear_wheels:
			front_load -= r.directional_force.y
			total += r.directional_force.y
		
		if total > 0:
			weight_dist[0] = (front_load / total) * 0.5 + 0.5
			weight_dist[1] = 1.0 - weight_dist[0]
	
	_readout_torque = multivariate()

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

func multivariate() -> float:
	#car uses _turbopsi for PSI, this may be inaccurate to other uses of the function
	
	var value:float = 0.0
	
	var maxpsi:float = 0.0
	var scrpm:float = 0.0
	var f:float = 0.0
	var j:float = 0.0
	
	#if car.SCEnabled:
	if SuperchargerEnabled:
		maxpsi = _turbopsi
		scrpm = _rpm
		scrpm = _rpm * SCRPMInfluence
		_turbopsi = (scrpm / 10000.0) * BlowRate - SCThreshold
		_turbopsi = clampf(_turbopsi, 0.0, maxpsi)
	
	#if not car.SCEnabled and not car.TEnabled:
	if not SuperchargerEnabled and not TurboEnabled:
		_turbopsi = 0.0
	
	var torque_local:ViVeCarTorque 
	if _rpm > VVTRPM:
		torque_local = torque_vvt
	else:
		torque_local = torque_norm
	
	value = (_rpm * torque_local.BuildUpTorque + torque_local.OffsetTorque) + ( (_turbopsi * TurboAmount) * (EngineCompressionRatio * 0.609) )
	f = _rpm - torque_local.RiseRPM
	f = maxf(f, 0.0)
	
	value += (f * f) * (torque_local.TorqueRise / 10000000.0)
	j = _rpm - torque_local.DeclineRPM
	j = maxf(j, 0.0)
	
	value /= (j * (j * torque_local.DeclineSharpness + (1.0 - torque_local.DeclineSharpness))) * (torque_local.DeclineRate / 10000000.0) + 1.0
	value /= pow(_rpm, 2) * (torque_local.FloatRate / 10000000.0) + 1.0
	
	value -= _rpm / ((absf(pow(_rpm, 2))) / EngineFriction + 1.0)
	value -= _rpm * EngineDrag
	
	return value
