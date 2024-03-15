extends Resource
## Anti-lock Braking System. 
class_name ViVeABS

## Threshold.
@export var threshold:float = 2500.0 #0
## Pump time.
@export var pump_time:int = 1 #1
## Vehicle speed before activation.
@export var speed_pre_active:float = 10.0 #2
## Enabled.
@export var enabled:bool = true #3
## Pump force.
@export_range(0.0, 1.0) var pump_force:float = 0.5 #4
## Lateral threshold.
@export var lat_thresh:float = 500.0 #5
## Lateral pump time.
@export var lat_pump_time:float = 2.0 #6

var orig_reference:Array = [ # anti-lock braking system
2500.0, # threshold
1, # pump time
10, # vehicle speed before activation
true, # enabled
0.5, # pump force (0.0 - 1.0)
500.0, # lateral threshold
2, # lateral pump time
]
