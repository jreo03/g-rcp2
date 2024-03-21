extends Node3D

@export var backfire_FuelRichness:float = 0.2
@export var backfire_FuelDecay:float = 0.1
@export var backfire_Air:float = 0.02
@export var backfire_BackfirePrevention:float = 0.1
@export var backfire_BackfireThreshold:float = 1.0
@export var backfire_BackfireRate:float = 1.0
@export var backfire_Volume:float = 0.5

@export var WhinePitch:float = 4 #could be an int?
@export var WhineVolume:float = 0.4
 
@export var BlowOffBounceSpeed:float = 0.0
@export var BlowOffWhineReduction:float = 1.0
@export var BlowDamping:float = 0.25
@export var BlowOffVolume:float = 0.5
@export var BlowOffVolume2:float = 0.5
@export var BlowOffPitch1:float = 0.5
@export var BlowOffPitch2:float = 1.0
@export var MaxWhinePitch:float = 1.8
@export var SpoolVolume:float = 0.5
@export var SpoolPitch:float = 0.5
@export var BlowPitch:float = 1.0
@export var TurboNoiseRPMAffection:float = 0.25

@export var engine_sound:NodePath = NodePath("../engine_sound")
var engine_node:ViVeCarEngineSFX
@export var exhaust_particles :Array[CPUParticles3D] = []

@export var volume:float = 0.25
var blow_psi:float = 0.0
var blow_inertia:float = 0.0

var fueltrace:float = 0.0
var air:float = 0.0
var rand:float = 0.0

var car:ViVeCar = get_parent()

@onready var scwhine:AudioStreamPlayer3D = $"scwhine"
@onready var whistle:AudioStreamPlayer3D = $"whistle"
@onready var blow:AudioStreamPlayer3D = $"blow"
@onready var backfire:AudioStreamPlayer3D = $"backfire"
@onready var spool:AudioStreamPlayer3D = $"spool"
@onready var whigh:AudioStreamPlayer3D = $"whigh"
@onready var wlow:AudioStreamPlayer3D = $"wlow"

func play() -> void:
	blow.stop()
	spool.stop()
	whistle.stop()
	scwhine.stop()
	whigh.play()
	wlow.play()
	if car.TurboEnabled:
		blow.play()
		spool.play()
		whistle.play()
	if car.SuperchargerEnabled:
		scwhine.play()

func stop() -> void:
	for i:AudioStreamPlayer3D in get_children():
		i.stop()

func _ready() -> void:
	car = get_parent_node_3d()
	play()

func _physics_process(_delta:float) -> void:
	fueltrace += (car._throttle) * backfire_FuelRichness
	air = (car._throttle * car._rpm) * backfire_Air + car._turbopsi
	
	fueltrace -= fueltrace * backfire_FuelDecay
	
	fueltrace = maxf(fueltrace, 0.0)
	
	engine_node = get_node(engine_sound)
	
	if has_node(engine_sound):
		engine_node.pitch_influence -= (engine_node.pitch_influence - 1.0) * 0.5
	
	if car._rpm > car.DeadRPM:
		if fueltrace > randf_range(air * backfire_BackfirePrevention + backfire_BackfireThreshold, 60.0 / backfire_BackfireRate):
			rand = 0.1
			var ft:float = maxf(fueltrace, 10.0)
			
			backfire.play()
			var yed:float = 1.5 - ft * 0.1
			yed = maxf(yed, 1.0)
			
			backfire.pitch_scale = randf_range(yed * 1.25, yed * 1.5)
			backfire.volume_db = linear_to_db((ft * backfire_Volume) * 0.1)
			backfire.max_db = backfire.volume_db
			engine_node.pitch_influence = 0.5
			for i:CPUParticles3D in exhaust_particles:
				i.emitting = true
		else:
			for i:CPUParticles3D in exhaust_particles:
				i.emitting = false
	
	var wh:float = abs(car._rpm / 10000.0) * WhinePitch
	wh = maxf(wh, 0.0)
	
	if wh > 0.01:
		scwhine.volume_db = linear_to_db(WhineVolume * volume)
		scwhine.max_db = scwhine.volume_db
		scwhine.pitch_scale = wh
	else:
		scwhine.volume_db = linear_to_db(0.0)
	
	var dist:float = blow_psi - car._turbopsi
	blow_psi -= (blow_psi - car._turbopsi) * BlowOffWhineReduction
	blow_inertia += blow_psi - car._turbopsi
	blow_inertia -= (blow_inertia - (blow_psi - car._turbopsi)) * BlowDamping
	blow_psi -= blow_inertia * BlowOffBounceSpeed
	
	blow_psi = minf(blow_psi, car.MaxPSI)
	
	var blowvol:float = dist
	
	blowvol = clampf(blowvol, 0.0, 1.0)
	
	var spoolvol:float = car._turbopsi / 10.0
	
	spoolvol = clampf(spoolvol, 0.0, 1.0)
	
	spoolvol += (abs(car._rpm) * (TurboNoiseRPMAffection / 1000.0)) * spoolvol
	
	var blow_local:float = linear_to_db(volume * (blowvol * BlowOffVolume2))
	blow_local = maxf(blow_local, -60.0)
	
	var spool_local:float = linear_to_db(volume * (spoolvol * SpoolVolume))
	spool_local = maxf(spool_local, -60.0)
	
	blow.volume_db = blow_local
	spool.volume_db = spool_local
	
	blow.max_db = blow.volume_db
	spool.max_db = spool.volume_db
	var yes:float = blowvol * BlowOffVolume
	yes = clampf(yes, 0.0, 1.0)
	var whistle_local:float = linear_to_db(yes)
	whistle_local = maxf(whistle_local, -60.0)
	
	whistle.volume_db = whistle_local
	whistle.max_db = whistle.volume_db
	
	var wps:float = 1.0
	if car._turbopsi > 0.0:
		wps = blowvol * BlowOffPitch2 + car._turbopsi * 0.05 + BlowOffPitch1
	else:
		wps = blowvol * BlowOffPitch2 + BlowOffPitch1
	wps = minf(wps, MaxWhinePitch)
	
	whistle.pitch_scale = wps
	spool.pitch_scale = SpoolPitch + spoolvol * 0.5
	blow.pitch_scale = BlowPitch
	
	var h:float = car._whinepitch / 200.0
	h = clampf(h, 0.5, 1.0)
	
	var wlow_local:float = linear_to_db(((car._gearstress * car.GearGap) / 160000.0) * ((1.0 - h) * 0.5))
	wlow_local = maxf(wlow_local, -60.0)
	
	wlow.volume_db = wlow_local
	wlow.max_db = wlow.volume_db
	if car._whinepitch / 50.0 > 0.0001:
		wlow.pitch_scale = car._whinepitch / 50.0
	var whigh_local:float = linear_to_db(((car._gearstress * car.GearGap) / 80000.0) * 0.5)
	whigh_local = maxf(whigh_local, -60.0)
	
	whigh.volume_db = whigh_local
	whigh.max_db = whigh.volume_db
	if car._whinepitch / 100.0 > 0.0001:
		whigh.pitch_scale = car._whinepitch / 100.0





