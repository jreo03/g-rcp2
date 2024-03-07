extends Resource
class_name ViVeCarTransmission

var su:bool = false
var sd:bool = false
var clutch:bool

var gear:int = 0
var clutchpedal:float = 0.0
var clutchin:bool = false
var clutchpedalreal:float = 0.0
var clock_mult:float = 1.0
var ratio:float = 0.0

@export var UseMouseSteering :bool = false

@export_enum("Fully Manual", "Automatic", "Continuously Variable", "Semi-Auto") var TransmissionType:int = 0
enum TransmissionIs {
	FULLY_MANUAL,
	AUTOMATIC,
	CONTINUOUSLY_VARIABLE,
	SEMI_AUTO
}

@export var GearAssist:GearAssistant = GearAssistant.new()

@export var OnClutchRate:float = 0.2
@export var OffClutchRate:float = 0.2
@export var MaxClutch:int = 1 #changed from float to int

@export_group("Ratios")
@export var GearRatios :Array[float] = [ 3.250, 1.894, 1.259, 0.937, 0.771 ]
@export var RatioMult:float = 9.5
@export var ReverseRatio:float = 3.153

@export var FinalDriveRatio:float = 4.250

