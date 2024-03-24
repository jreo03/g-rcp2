extends Resource
## @experimental
## Electronic Stability Program. [br] CURRENTLY DOESN'T WORK!
class_name ViVeESP

## Stabilization threshold.
@export var stab_thresh:float = 0.5 #0
## Stabilisation rate Higher = understeer, understeer = inefficient.
@export var stab_rate:float = 1.5
## Yaw threshold.
@export var yaw_thresh:float = 1
## Yaw rate.
@export var yaw_rate: float = 3.0
## Enabled.
@export var enabled:bool = false

var orig_reference:Array = [ # electronic stability program
0.5, # stabilisation theshold
1.5, # stabilisation rate (higher = understeer, understeer = inefficient)
1, # yaw threshold
3.0, # yaw rate
false, # enableda
]
