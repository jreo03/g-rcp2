extends Node3D
##The singleton representing the base of the SceneTree in a VitaVehicle instance.
class_name ViVeEnvironment

##The ViVeEnvironment singleton
##NOTE:Using this is considered unsafe in comparison to calling [method ViVeEnvironment.get_singleton]
static var singleton:ViVeEnvironment = null

var Debug_Mode:bool = true

##The currently active player car.
##NOTE: Could be changed in the future to accomodate multiple player cars, but right now acts singularly.
@onready var car:ViVeCar = $"car":
	set(new):
		car = new
		var _err:Error = emit_signal("car_changed")

##The currently loaded play scene.
@onready var scene:Node3D = $"test scene":
	set(new):
		scene = new
		var _err:Error = emit_signal("scene_changed")

@onready var env:WorldEnvironment = $"Morning_env"

##Emitted when the car is changed. 
##NOTE: Could be changed in the future to accomodate multiple player cars, but right now acts singularly.
signal car_changed
##Emitted when the play scene changes.
signal scene_changed

func _init() -> void:
	singleton = self

##Safer version of just using the singleton variable, even tho the variable is 
##what's currently used in the codebase :P
static func get_singleton() -> ViVeEnvironment:
	if singleton != null:
		return singleton
	else:
		return ViVeEnvironment.new()
