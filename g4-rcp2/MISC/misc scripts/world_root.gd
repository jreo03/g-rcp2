extends WorldEnvironment
##The singleton representing the base of the SceneTree in a VitaVehicle instance.
class_name ViVeEnvironment

##The ViVeEnvironment singleton
##NOTE:Using this is considered unsafe in comparison to calling [method ViVeEnvironment.get_singleton]
static var singleton:ViVeEnvironment = null

var current_sky:Environment = environment
const default_sky:Environment = preload("res://default_env.tres")
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

@onready var sun:DirectionalLight3D = $"morning_sun"

##Emitted when the car is changed. 
##NOTE: Could be changed in the future to accomodate multiple player cars, but right now acts singularly.
signal car_changed
##Emitted when the play scene changes.
signal scene_changed

##Emiited when the Environment changes
signal env_changed

func _init() -> void:
	singleton = self

##Safer version of just using the singleton variable, even tho the variable is 
##what's currently used in the codebase :P
static func get_singleton() -> ViVeEnvironment:
	if singleton != null:
		return singleton
	else:
		return ViVeEnvironment.new()


func switch_sky(procedural:bool) -> void:
	if misc_graphics_settings.use_procedural_sky:
		environment = current_sky
	else:
		environment = default_sky

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_debug_mode"):
		if Debug_Mode:
			Debug_Mode = false
			car.Debug_Mode = false
		else:
			Debug_Mode = true
			car.Debug_Mode = true
