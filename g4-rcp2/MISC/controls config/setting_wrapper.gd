extends Resource
class_name ViVeCarControlOption

static var control_ref:ViVeCarControls = null

@export var var_name:String = ""

func set_var(input:Variant) -> void:
	control_ref.set(var_name, input)

func _init(name:String = "") -> void:
	if name != "":
		var_name = name
