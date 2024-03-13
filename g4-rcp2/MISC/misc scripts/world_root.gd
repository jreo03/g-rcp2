extends Node3D
class_name ViVeEnvironment

static var singleton:ViVeEnvironment = null

@onready var car:ViVeCar = $"car":
	set(new):
		car = new
		emit_signal("car_changed")

@onready var scene:Node3D = $"test scene"

signal car_changed
signal scene_changed

func _init() -> void:
	singleton = self

static func get_singleton() -> ViVeEnvironment:
	if singleton != null:
		return singleton
	else:
		return ViVeEnvironment.new()
