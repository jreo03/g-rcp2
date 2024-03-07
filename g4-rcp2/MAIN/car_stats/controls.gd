extends Resource
class_name ViveControls

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

@export var LooseSteering:bool = false #simulate rack and pinion steering physics (EXPERIMENTAL)

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
