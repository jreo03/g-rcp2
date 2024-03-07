extends Resource
class_name ViVeCVT

@export var throt_eff_thresh:float = 0.75 #0
@export var accel_rate:float = 0.025 #1
@export var iteration_1:float = 0.9 #2
@export var iteration_2:float = 500.0 #3
@export var iteration_3:float = 2.0 #4
@export var iteration_4: float = 0.2 #5

var reference:Array[float] = [
0.75, # throttle efficiency threshold (range: 0 - 1)
0.025, # acceleration rate (range: 0 - 1)
0.9, # iteration 1 (higher = higher rpm)
500.0, # iteration 2 (higher = better acceleration from standstill but unstable)
2.0, # iteration 3 (higher = longer it takes to "lock" the rpm)
0.2, # iteration 4 (keep it over 0.1)
]
