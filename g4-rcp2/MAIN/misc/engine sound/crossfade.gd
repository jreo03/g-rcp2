extends Node3D

var pitch:float = 0.0
var volume:float = 0.0
var fade:float = 0.0

var vacuum:float = 0.0
var maxfades:float = 0.0

@export var pitch_calibrate:float = 7500.0
@export var vacuum_crossfade:float = 0.7
@export var vacuum_loudness:float = 4.0
@export var crossfade_vvt:float = 5.0
@export var crossfade_throttle:float = 0.0
@export var crossfade_influence:float = 5.0
@export var overall_volume:float = 1.0

var pitch_influence:float = 1.0

func play():
	for i in get_children():
		i.play()
#	stop()
		
func stop():
	for i in get_children():
		i.stop()

var childcount:int = 0

func _ready():
	play()
	childcount = get_child_count()
	maxfades = float(childcount-1.0)

func _physics_process(_delta):
	
	pitch = abs(get_parent().rpm*pitch_influence)/pitch_calibrate
	
	volume = 0.5 +get_parent().throttle*0.5
	fade = (get_node("100500").pitch_scale  -0.22222)*(crossfade_influence +float(get_parent().throttle)*crossfade_throttle +float(get_parent().vvt)*crossfade_vvt)
	
	fade = clampf(fade, childcount-1, 0.0)
	
	vacuum = (get_parent().gaspedal-get_parent().throttle)*4
	
	vacuum = clampf(vacuum, 0, 1)
	
	var sfk:float = 1.0-(vacuum*get_parent().throttle)
	
	if sfk < vacuum_crossfade:
		sfk = vacuum_crossfade
	
	fade *= sfk
	
	volume += (1.0-sfk)*vacuum_loudness
	
	for i in get_children():
		var maxvol = float(str(i.get_child(0).name))/100.0
		var maxpitch = float(str(i.name))/100000.0
		
		var index = float(i.get_index())
		var dist = abs(index-fade)
		
		dist *= abs(dist)
		
		var vol:float = 1.0-dist
		vol = clampf(vol, 0.0, 1.0)
		
		var db = linear_to_db((vol*maxvol)*(volume*(overall_volume)))
		if db < -60.0:
			db = -60.0
			
		i.volume_db = db
		i.max_db = i.volume_db
		var pit = abs(pitch*maxpitch)
		pit = clampf(pit, 0.01, 5.0)
		
		i.pitch_scale = pit

