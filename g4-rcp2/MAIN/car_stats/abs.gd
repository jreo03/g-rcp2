extends Resource
class_name ViVeABS

@export var threshold:float = 2500.0 #0
@export var pump_time:int = 1 #1
@export var speed_pre_active:float = 10.0 #2
@export var enabled:bool = true #3
@export var pump_force:float = 0.5 #4
@export var lat_thresh:float = 500.0 #5
@export var lat_pump_time:float = 2.0 #6

var reference:Array = [ # anti-lock braking system
2500.0, # threshold
1, # pump time
10, # vehicle speed before activation
true, # enabled
0.5, # pump force (0.0 - 1.0)
500.0, # lateral threshold
2, # lateral pump time
]
