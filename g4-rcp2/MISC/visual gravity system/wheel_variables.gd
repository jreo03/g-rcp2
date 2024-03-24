extends Polygon2D
class_name ViVeDebugWheel

@onready var slippage:Polygon2D = $"slippage"
@onready var background:Polygon2D = $"background"

var pos:Vector2
var setting:ViVeTyreSettings
var node:ViVeWheel
