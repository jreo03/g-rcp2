extends Resource
## Prevents wheel slippage by partially closing the throttle. [br] CURRENTLY DOESN'T WORK!
class_name ViVeTTCS

@export var threshold:float = 5
@export var sensitivity:float = 1.0
@export var enabled:bool = false

var orig_reference:Array = [ # throttle-based traction control system
5, # threshold
1.0, # sensitivity
false, # enabled
]
