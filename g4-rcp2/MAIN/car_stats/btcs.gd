extends Resource
class_name ViVeBTCS

@export var threshold:float = 10 #0
@export var sensitivity:float = 0.05 #1
@export var enabled:bool = true #2

var reference:Array = [ # brake-based traction control system
10, # threshold
0.05, # sensitivity
false, # enabled
]
