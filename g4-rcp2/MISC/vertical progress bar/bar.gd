extends ColorRect

@export var bar_scale:float = 0.0


func _process(_delta:float) -> void:
	$ColorRect.pivot_offset.y = size.y
	$ColorRect.scale.y = bar_scale
