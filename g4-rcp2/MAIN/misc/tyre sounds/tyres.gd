extends Node3D

var length:float = 0.0
var width:float = 0.0
var weight:float = 0.0
var dirt:float = 0.0

var wheels:Array[ViVeWheel] = []

@onready var roll0:ViVeWheelSFX = $"roll0"
@onready var roll1:ViVeWheelSFX = $"roll1"
@onready var roll2:ViVeWheelSFX = $"roll2"
@onready var peel0:ViVeWheelSFX = $"peel0"
@onready var peel1:ViVeWheelSFX = $"peel1"
@onready var peel2:ViVeWheelSFX = $"peel2"

var parent:ViVeCar = null

func play() -> void:
	for i:AudioStreamPlayer3D in get_children():
		i.volume_db = linear_to_db(0.0)
		i.play()

func stop() -> void:
	for i:AudioStreamPlayer3D in get_children():
		i.stop()

func _ready() -> void:
	parent = get_parent_node_3d()
	var _err:Error = parent.connect("wheels_ready", load_wheels)
	
	play()

func load_wheels() -> void:
	wheels = parent.get_wheels()

func most_skidding(array:Array[ViVeWheel]) -> ViVeWheel:
	var val:float = -10000000000000000000000000000000000.0
	var obj:ViVeWheel
	for i:ViVeWheel in array:
		val = maxf(val, absf(i.skvol))
		if val == absf(i.skvol):
			obj = i
	return obj

func _physics_process(_delta:float) -> void:
	dirt = 0.0
	for i:ViVeWheel in wheels:
		dirt += float(i.surface_vars.ground_dirt) / len(wheels)
	
	var wheel:ViVeWheel = most_skidding(wheels)
	
	length = minf((wheel.skvol / 2.0 - 1.0), 2.0)
	
	var roll:float = absf(wheel.wv * wheel.w_size) - wheel.velocity.length()
	
	width -= (width - (1.0 - (roll / 10.0 - 1.0))) * 0.05
	
	width = clampf(width, 0.0, 1.0)
	
	var total:float = 0.0
	
	for i:ViVeWheel in wheels:
		total += i.skvol
	
	total /= 10.0
	
	total = minf(total, 1.0)
	
	var mult:float = (parent.linear_velocity.length() / 5000.0 + 1.0)
	
	#roll0.pitch_scale = 1.0 / (parent.linear_velocity.length() / 500.0 + 1.0)
	roll1.pitch_scale = 1.0 / mult
	roll2.pitch_scale = 1.0 / mult
	peel0.pitch_scale = 0.95 + length / 8.0 / mult
	peel1.pitch_scale = 1.0 / mult
	peel2.pitch_scale =  1.1 - total * 0.1 / mult
	
	
	var drit:float = (parent.linear_velocity.length() * wheel.stress) / 1000.0 - 0.1
	
	drit = minf(drit, 0.5)
	
	drit += wheel.skvol / 2.0 - 0.1
	
	drit = clampf(drit, 0.0, 1.0)
	
	drit *= dirt
	
	for i:ViVeWheelSFX in get_children():
		if i.name == "dirt":
			i.volume_db = linear_to_db(drit * 0.3)
			i.max_db = i.volume_db
			i.pitch_scale = 1.0 + length * 0.05 + absf(roll / 100.0)
		else:
			var dist:float = absf(i.length - length)
			var dist2:float = absf(i.width - width)
			
			dist *= absf(dist)
			dist2 *= absf(dist2)
			
			var vol:float = 1.0 - (dist + dist2)
			vol = clampf(vol, 0.0, 1.0)
			
			i.volume_db = linear_to_db(((vol * (1.0 - dirt)) * i.volume) * 0.35)
			i.max_db = i.volume_db
