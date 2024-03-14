extends CheckBox

var option:ViVeCarControlOption

@export var var_name:String = ""

@onready var amount:Label = $amount

func _ready() -> void:
	option = ViVeCarControlOption.new(var_name)
	connect("toggled", _on_toggled)

func _on_toggled(active:bool) -> void:
	option.set_var(active)
	amount.text = str(active)
