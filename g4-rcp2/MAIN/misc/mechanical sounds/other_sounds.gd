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
@export var exhaust_particles :Array[NodePath] = []

@export var volume:float = 0.25
var blow_psi:float = 0.0
var blow_inertia:float = 0.0

var fueltrace:float = 0.0
var air:float = 0.0
var rand:float = 0.0

func play() -> void:
	$blow.stop()
	$spool.stop()
	$whistle.stop()
	$scwhine.stop()
	$whigh.play()
	$wlow.play()
	if get_parent().TurboEnabled:
		$blow.play()
		$spool.play()
		$whistle.play()
	if get_parent().SuperchargerEnabled:
		$scwhine.play()

func stop() -> void:
	for i:AudioStreamPlayer3D in get_children():
		i.stop()

func _ready() -> void:
	play()

func _physics_process(_delta:float) -> void:
	fueltrace += (get_parent().throttle) * backfire_FuelRichness
	air = (get_parent().throttle * get_parent().rpm) * backfire_Air +get_parent().turbopsi
	
	fueltrace -= fueltrace * backfire_FuelDecay
	
	fueltrace = maxf(fueltrace, 0.0)
	
	if has_node(engine_sound):
		get_node(engine_sound).pitch_influence -= (get_node(engine_sound).pitch_influence - 1.0) * 0.5
	
	if get_parent().rpm > get_parent().DeadRPM:
		if fueltrace > randf_range(air * backfire_BackfirePrevention + backfire_BackfireThreshold, 60.0 / backfire_BackfireRate):
			rand = 0.1
			var ft:float = maxf(fueltrace, 10.0)
			
			$backfire.play()
			var yed:float = 1.5 - ft * 0.1
			yed = maxf(yed, 1.0)
			
			$backfire.pitch_scale = randf_range(yed * 1.25,yed * 1.5)
			$backfire.volume_db = linear_to_db((ft * backfire_Volume) * 0.1)
			$backfire.max_db = $backfire.volume_db
			get_node(engine_sound).pitch_influence = 0.5
			for i in exhaust_particles:
				get_node(i).emitting = true
		else:
			for i in exhaust_particles:
				get_node(i).emitting = false
	
	var wh:float = abs(get_parent().rpm / 10000.0) * WhinePitch
	wh = maxf(wh, 0.0)
	
	if wh > 0.01:
		$scwhine.volume_db = linear_to_db(WhineVolume * volume)
		$scwhine.max_db = $scwhine.volume_db
		$scwhine.pitch_scale = wh
	else:
		$scwhine.volume_db = linear_to_db(0.0)
	
	var dist:float = blow_psi - get_parent().turbopsi
	blow_psi -= (blow_psi - get_parent().turbopsi) * BlowOffWhineReduction
	blow_inertia += blow_psi - get_parent().turbopsi
	blow_inertia -= (blow_inertia - (blow_psi - get_parent().turbopsi)) * BlowDamping
	blow_psi -= blow_inertia * BlowOffBounceSpeed
	
	blow_psi = minf(blow_psi, get_parent().MaxPSI)
	
	var blowvol:float = dist
	
	blowvol = clampf(blowvol, 0.0, 1.0)
	
	var spoolvol:float = get_parent().turbopsi / 10.0
	
	spoolvol = clampf(spoolvol, 0.0, 1.0)
	
	spoolvol += (abs(get_parent().rpm) * (TurboNoiseRPMAffection / 1000.0)) * spoolvol
	
	var blow:float = linear_to_db(volume * (blowvol * BlowOffVolume2))
	blow = maxf(blow, -60.0)
	
	var spool:float = linear_to_db(volume * (spoolvol * SpoolVolume))
	spool = maxf(spool, -60.0)
	
	$blow.volume_db = blow
	$spool.volume_db = spool
	
	$blow.max_db = $blow.volume_db
	$spool.max_db = $spool.volume_db
	var yes:float = blowvol * BlowOffVolume
	yes = clampf(yes, 0.0, 1.0)
	var whistle:float = linear_to_db(yes)
	whistle = maxf(whistle, -60.0)
	
	$whistle.volume_db = whistle
	$whistle.max_db = $whistle.volume_db
	
	var wps:float = 1.0
	if get_parent().turbopsi > 0.0:
		wps = blowvol * BlowOffPitch2 + get_parent().turbopsi * 0.05 + BlowOffPitch1
	else:
		wps = blowvol * BlowOffPitch2 + BlowOffPitch1
	wps = minf(wps, MaxWhinePitch)
	
	$whistle.pitch_scale = wps
	$spool.pitch_scale = SpoolPitch + spoolvol * 0.5
	$blow.pitch_scale = BlowPitch
	
	var h:float = get_parent().whinepitch / 200.0
	h = clampf(h, 0.5, 1.0)
	
	var wlow:float = linear_to_db(((get_parent().gearstress * get_parent().GearGap) / 160000.0) * ((1.0 - h) * 0.5))
	wlow = maxf(wlow, -60.0)
	
	$wlow.volume_db = wlow
	$wlow.max_db = $wlow.volume_db
	if get_parent().whinepitch / 50.0 > 0.0001:
		$wlow.pitch_scale = get_parent().whinepitch / 50.0
	var whigh:float = linear_to_db(((get_parent().gearstress*get_parent().GearGap) / 80000.0) * 0.5)
	whigh = maxf(whigh, -60.0)
	
	$whigh.volume_db = whigh
	$whigh.max_db = $whigh.volume_db
	if get_parent().whinepitch / 100.0 > 0.0001:
		$whigh.pitch_scale = get_parent().whinepitch / 100.0





