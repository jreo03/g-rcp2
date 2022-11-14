extends Spatial

var pitch = 0.0
var volume = 0.0
var fade = 0.0

var vacuum = 0.0
var maxfades = 0.0

export var pitch_calibrate = 7500.0
export var vacuum_crossfade = 0.7
export var vacuum_loudness = 4.0
export var crossfade_vvt = 5.0
export var crossfade_throttle = 0.0
export var crossfade_influence = 5.0
export var overall_volume = 1.0

var pitch_influence = 1.0

func play():
	for i in get_children():
		i.play()
#	stop()
		
func stop():
	for i in get_children():
		i.stop()

var childcount = 0

func _ready():
	play()
	childcount = get_child_count()
	maxfades = float(childcount-1.0)

func _physics_process(_delta):


	pitch = abs(get_parent().rpm*pitch_influence)/pitch_calibrate
	
	volume = 0.5 +get_parent().throttle*0.5
	fade = (get_node("100500").pitch_scale  -0.22222)*(crossfade_influence +float(get_parent().throttle)*crossfade_throttle +float(get_parent().vvt)*crossfade_vvt)
		
	if fade<0.0:
		fade = 0.0
	elif fade>childcount-1.0:
		fade = childcount-1.0
	
	vacuum = (get_parent().gaspedal-get_parent().throttle)*4

	if vacuum<0:
		 vacuum = 0
	elif vacuum>1:
		 vacuum = 1

	var sfk = 1.0-(vacuum*get_parent().throttle)
	
	if sfk<vacuum_crossfade:
		 sfk = vacuum_crossfade
	
	fade *= sfk
	
	volume += (1.0-sfk)*vacuum_loudness

	
	
	for i in get_children():
		var maxvol = float(i.get_child(0).name)/100.0
		var maxpitch = float(i.name)/100000.0
		
		var index = float(i.get_index())
		var dist = abs(index-fade)
		
		dist *= abs(dist)
		
		var vol = 1.0-dist
		if vol<0.0:
			vol = 0.0
		elif vol>1.0:
			vol = 1.0
		var db = linear2db((vol*maxvol)*(volume*(overall_volume)))
		if db<-60.0:
			db = -60.0
			
		i.unit_db = db
		i.max_db = i.unit_db
		var pit = abs(pitch*maxpitch)
		if pit>5.0:
			pit = 5.0
		elif pit<0.01:
			pit = 0.01
		i.pitch_scale = pit
	
		
