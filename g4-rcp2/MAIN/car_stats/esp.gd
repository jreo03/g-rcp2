extends Resource
class_name ViVeESP

@export var stab_thresh:float = 0.5 #0
@export var stab_rate:float = 1.5
@export var yaw_thresh:float = 1
@export var yaw_rate: float = 3.0
@export var enabled:bool = false

var reference:Array = [ # electronic stability program
0.5, # stabilisation theshold
1.5, # stabilisation rate (higher = understeer, understeer = inefficient)
1, # yaw threshold
3.0, # yaw rate
false, # enableda
]
