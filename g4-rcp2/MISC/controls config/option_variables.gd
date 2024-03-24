extends OptionButton

var option:ViVeCarControlOption

@export var var_name:String = ""

func _ready() -> void:
	option = ViVeCarControlOption.new(var_name)
	connect("item_selected", _on_item_selected)

func _on_item_selected(itm:int) -> void:
	option.set_var(itm)
