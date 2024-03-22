extends Node2D

class_name ViVeTouchControls

@export var base_resolution:Vector2 = Vector2(1024,600)

static var singleton:ViVeTouchControls

func _ready() -> void:
	singleton = self
