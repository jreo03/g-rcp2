extends Resource
##A resource containing torque related variables.
##If "VVT" is used as a construct parameter, it will instantiate with VVT variables.
## [br] VVT variables are the second iteration. 
## Vehicles will select VVT settings when RPMs reach a certain point (VVTRPM), portrayed as Variable Valve Timing.
class_name ViVeCarTorque

#@export variable valve timing triggered
##Torque buildup relative to RPM. VVT default is 0.0.
@export var BuildUpTorque:float = 0.0035
##Sqrt torque buildup relative to RPM. VVT default is 60.0.
@export var TorqueRise:float = 30.0
##Initial RPM for TorqueRise. VVT default is 1000.0.
@export var RiseRPM:float = 1000.0
##Static torque. VVT default is 70.0.
@export var OffsetTorque:float = 110.0
##Torque reduction relative to RPM. VVT default is 0.1.
@export var FloatRate:float = 0.1
##Rapid reduction of torque. VVT default is 2.0.
@export var DeclineRate:float = 1.5
##Initial RPM for DeclineRate. VVT default is 5000.0.
@export var DeclineRPM:float = 3500.0
##VVT default is 1.0.
@export var DeclineSharpness:float = 1.0

func _init(variation:String = "") -> void:
	if variation == "VVT":
		BuildUpTorque = 0.0
		TorqueRise = 60.0
		RiseRPM = 1000.0
		OffsetTorque = 70.0
		FloatRate = 0.1
		DeclineRate = 2.0
		DeclineRPM = 5000.0
		DeclineSharpness = 1.0
