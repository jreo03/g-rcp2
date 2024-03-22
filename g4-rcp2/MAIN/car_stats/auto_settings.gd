extends Resource

##Transmission automation settings (for Automatic, CVT and Semi-Auto).
class_name ViVeAutoSettings

## Upshift RPM (auto).
@export var shift_rpm:float = 6500.0 #0
## Downshift threshold (auto).
@export var downshift_thresh:float = 300.0 #1
## Throttle efficiency threshold (auto/dct).
@export_range(0, 1) var throt_eff_thresh:float = 0.5 #2
## Engagement rpm threshold (auto/dct/cvt).
@export var engage_rpm_thresh:float = 0.0 #3
## Engagement rpm (auto/dct/cvt).
@export var engage_rpm:float = 4000.0 #4

#@export var AutoSettings:Array[float] = [
#6500.0, # shift rpm (auto)
#300.0, # downshift threshold (auto)
#0.5, # throttle efficiency threshold (range: 0 - 1) (auto/dct)
#0.0, # engagement rpm threshold (auto/dct/cvt)
#4000.0, # engagement rpm (auto/dct/cvt)
#]
