extends Resource
class_name GearAssistant

@export var shift_delay:int = 20 #0
@export var assist_level:int = 2 #1
@export var speed_influence:float = 0.944087 #2
@export var down_RPM:float = 6000.0 #3
@export var upshift_RPM:float = 6200.0 #4
@export var clutch_out_RPM:float = 3000.0 #5
@export var input_delay:int = 5 #6

#For reference:
#@export var _GearAssistant:Array[float] = [
#20, # Shift delay
#2, # Assistance Level (0 - 2)
#0.944087, # Speed Influence (will be automatically set)
#6000.0, # Downshift RPM Iteration
#6200.0, # Upshift RPM
#3000.0, # Clutch-Out RPM
#5, # throttle input allowed after shiting delay
#]
