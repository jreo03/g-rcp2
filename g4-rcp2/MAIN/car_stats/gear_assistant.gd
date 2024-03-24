extends Resource
## Gear Assistance.
class_name ViVeGearAssist

## Shift Delay.
@export var shift_delay:int = 20 #0
## Assistance Level.
## [br] 0 means the player will have to manually hold clutch and then shift up/down.
## [br] 1 means the player will only have to shift up/down.
## [br] 2 means the car is automatic.
@export_range(0, 2) var assist_level:int = 2 #1
## Speed influence relative to wheel sizes. (This will be set automatically).
@export var speed_influence:float = 0.944087 #2
## Downshift RPM.
@export var down_RPM:float = 6000.0 #3
## Upshift RPM.
@export var upshift_RPM:float = 6200.0 #4
## Clutch-Out RPM.
@export var clutch_out_RPM:float = 3000.0 #5
## Throttle input allowed after shifting delay.
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
