extends Resource
## Settings for CVT.
class_name ViVeCVT
## Throttle efficiency threshold.
@export_range(0.0, 1.0) var throt_eff_thresh:float = 0.75 #0
## Acceleration rate.
@export_range(0.0, 1.0) var accel_rate:float = 0.025 #1
## Iteration 1. Higher = higher RPM.
@export var iteration_1:float = 0.9 #2
## Iteration 2. Higher = better acceleration from standstill but unstable.
@export var iteration_2:float = 500.0 #3
## Iteration 3. Higher = longer it takes to "lock" the rpm.
@export var iteration_3:float = 2.0 #4
## Iteration 4. Keep it over 0.1.
@export var iteration_4: float = 0.2 #5

var _orig_reference:Array[float] = [
0.75, # throttle efficiency threshold (range: 0 - 1)
0.025, # acceleration rate (range: 0 - 1)
0.9, # iteration 1 (higher = higher rpm)
500.0, # iteration 2 (higher = better acceleration from standstill but unstable)
2.0, # iteration 3 (higher = longer it takes to "lock" the rpm)
0.2, # iteration 4 (keep it over 0.1)
]
