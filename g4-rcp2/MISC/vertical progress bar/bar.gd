extends ColorRect

@export var bar_scale:float = 0.0

@onready var c_r:ColorRect = $"ColorRect"

func _process(_delta:float) -> void:
	c_r.pivot_offset.y = size.y
	c_r.scale.y = bar_scale
