extends Node
class_name ViVeCarTorque

#@export variable valve timing triggered
@export var BuildUpTorque:float = 0.0035
@export var TorqueRise:float = 30.0
@export var RiseRPM:float = 1000.0
@export var OffsetTorque:float = 110.0
@export var FloatRate:float = 0.1
@export var DeclineRate:float = 1.5
@export var DeclineRPM:float = 3500.0
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
