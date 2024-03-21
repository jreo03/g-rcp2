extends Node3D

class_name ViVeCarEngineSFX

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

#node_name: original_name
#snd_1: 450000
#snd_2: 300000
#snd_3: 225000
#snd_4: 178750
#snd_5: 150500
#snd_6: 126500
#snd_7: 112750
#snd_8: 100500

@onready var snd_8:ViVeEngineSound = $"snd_8"

var pitch_influence:float = 1.0

func play() -> void:
	for i:AudioStreamPlayer3D in get_children():
		i.play()
#	stop()

func stop() -> void:
	for i:AudioStreamPlayer3D in get_children():
		i.stop()

var childcount:int = 0

func _ready() -> void:
	play()
	childcount = get_child_count()
	maxfades = float(childcount - 1.0)

func _physics_process(_delta:float) -> void:
	var car:ViVeCar = get_parent_node_3d()
	pitch = abs(car._rpm * pitch_influence) / pitch_calibrate
	
	volume = 0.5 + car._throttle * 0.5
	
	fade = (snd_8.pitch_scale - 0.22222) * (crossfade_influence + car._throttle * crossfade_throttle + float(car._vvt) * crossfade_vvt)
	
	fade = clampf(fade, childcount - 1, 0.0)
	
	vacuum = (car.car_controls.gaspedal - car._throttle) * 4
	
	vacuum = clampf(vacuum, 0, 1)
	
	var sfk:float = 1.0 - (vacuum * car._throttle)
	
	sfk = maxf(sfk, vacuum_crossfade)
	
	fade *= sfk
	
	volume += (1.0 - sfk) * vacuum_loudness
	
	for i:ViVeEngineSound in get_children():
		#var maxvol:float = float(str(i.get_child(0).name)) / 100.0
		var maxvol:float = i.volume
		var maxpitch:float = i.pitch / 100000.0
		
		var index:float = float(i.get_index())
		var dist:float = absf(index - fade)
		
		dist *= absf(dist)
		
		var vol:float = clampf(1.0 - dist, 0.0, 1.0)
		
		var db:float = linear_to_db((vol * maxvol) * (volume * (overall_volume)))
		
		db = maxf(db, -60.0)
		
		i.volume_db = db
		i.max_db = i.volume_db
		var pit:float = clampf(absf(pitch * maxpitch), 0.01, 5.0)
		
		i.pitch_scale = pit

