extends HSlider

var option:ViVeCarControlOption

@export var var_name:String = ""
@export var treat_as_int:bool = false

@onready var text:Label = $"text"
@onready var amount:Label = $"amount"

var value_cache:float

func _ready() -> void:
	option = ViVeCarControlOption.new(var_name)
	connect("value_changed", _on_value_changed)
	connect("drag_ended", _on_drag_end)

func _on_value_changed(val:float) -> void:
	value_cache = val
	amount.text = str(val)

func _on_drag_end(_val_changed:bool) -> void:
	if treat_as_int:
		option.set_var(int(value_cache))
	else:
		option.set_var(value_cache)
