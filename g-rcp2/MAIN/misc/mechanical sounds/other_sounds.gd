extends Spatial

export var backfire_FuelRichness = 0.2
export var backfire_FuelDecay = 0.1
export var backfire_Air = 0.02
export var backfire_BackfirePrevention = 0.1
export var backfire_BackfireThreshold = 1.0
export var backfire_BackfireRate = 1.0
export var backfire_Volume = 0.5


export var WhinePitch = 4
export var WhineVolume = 0.4
 
export var BlowOffBounceSpeed = 0.0
export var BlowOffWhineReduction = 1.0
export var BlowDamping = 0.25
export var BlowOffVolume = 0.5
export var BlowOffVolume2 = 0.5
export var BlowOffPitch1 = 0.5
export var BlowOffPitch2 = 1.0
export var MaxWhinePitch = 1.8
export var SpoolVolume = 0.5
export var SpoolPitch = 0.5
export var BlowPitch = 1.0
export var TurboNoiseRPMAffection = 0.25

export var engine_sound = NodePath("../engine_sound")
export(Array,NodePath) var exhaust_particles = []

export var volume = 0.25
var blow_psi = 0.0
var blow_inertia = 0.0

var fueltrace = 0.0
var air = 0.0
var rand = 0.0

func play():
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
			
func stop():
	for i in get_children():
		i.stop()

func _ready():
	play()

func _physics_process(delta):
	fueltrace += (get_parent().throttle)*backfire_FuelRichness
	air = (get_parent().throttle*get_parent().rpm)*backfire_Air +get_parent().turbopsi

	fueltrace -= fueltrace*backfire_FuelDecay
	
	if fueltrace<0.0:
		fueltrace = 0.0
		
	
	if has_node(engine_sound):
		get_node(engine_sound).pitch_influence -= (get_node(engine_sound).pitch_influence - 1.0)*0.5

	if get_parent().rpm>get_parent().DeadRPM:
		if fueltrace>rand_range(air*backfire_BackfirePrevention +backfire_BackfireThreshold,60.0/backfire_BackfireRate):
			rand = 0.1
			var ft = fueltrace
			if ft<10:
				ft = 10
			$backfire.play()
			var yed = 1.5-ft*0.1
			if yed<1.0:
				yed = 1.0
			$backfire.pitch_scale = rand_range(yed*1.25,yed*1.5)
			$backfire.unit_db = linear2db((ft*backfire_Volume)*0.1)
			$backfire.max_db = $backfire.unit_db
			get_node(engine_sound).pitch_influence = 0.5
			for i in exhaust_particles:
				get_node(i).emitting = true
		else:
			for i in exhaust_particles:
				get_node(i).emitting = false

	
	
	var wh = abs(get_parent().rpm/10000.0)*WhinePitch
	if wh<0.0:
		wh = 0.0
	if wh>0.01:
		$scwhine.unit_db = linear2db(WhineVolume*volume)
		$scwhine.max_db = $scwhine.unit_db
		$scwhine.pitch_scale = wh
	else:
		$scwhine.unit_db = linear2db(0.0)


	var dist = blow_psi - get_parent().turbopsi
	blow_psi -= (blow_psi - get_parent().turbopsi)*BlowOffWhineReduction
	blow_inertia += blow_psi - get_parent().turbopsi
	blow_inertia -= (blow_inertia - (blow_psi - get_parent().turbopsi))*BlowDamping
	blow_psi -= blow_inertia*BlowOffBounceSpeed

	if blow_psi>get_parent().MaxPSI:
		blow_psi = get_parent().MaxPSI
		
		
	var blowvol = dist
	if blowvol<0.0:
		blowvol = 0.0
	elif blowvol>1.0:
		blowvol = 1.0
		
	var spoolvol = get_parent().turbopsi/10.0
	if spoolvol<0.0:
		spoolvol = 0.0
	elif spoolvol>1.0:
		spoolvol = 1.0

	spoolvol += (abs(get_parent().rpm)*(TurboNoiseRPMAffection/1000.0))*spoolvol

	

	var blow = linear2db(volume*(blowvol*BlowOffVolume2))
	if blow<-60.0:
		blow = -60.0
	var spool = linear2db(volume*(spoolvol*SpoolVolume))
	if spool<-60.0:
		spool = -60.0

	$blow.unit_db = blow
	$spool.unit_db = spool
	
	$blow.max_db = $blow.unit_db
	$spool.max_db = $spool.unit_db
	var yes = blowvol*BlowOffVolume
	if yes>1.0:
		yes = 1.0
	elif yes<0.0:
		yes = 0.0
	var whistle = linear2db(yes)
	if whistle<-60.0:
		whistle = -60.0
	$whistle.unit_db = whistle
	$whistle.max_db = $whistle.unit_db
	var wps = 1.0
	if get_parent().turbopsi>0.0:
		wps = blowvol*BlowOffPitch2 +get_parent().turbopsi*0.05 +BlowOffPitch1
	else:
		wps = blowvol*BlowOffPitch2 +BlowOffPitch1
	if wps>MaxWhinePitch:
		wps = MaxWhinePitch
	$whistle.pitch_scale = wps
	$spool.pitch_scale = SpoolPitch +spoolvol*0.5
	$blow.pitch_scale = BlowPitch


	var h = get_parent().whinepitch/200.0
	if h>1.0:
		h = 1.0
	elif h<0.5:
		h = 0.5
		
	var wlow = linear2db(((get_parent().gearstress*get_parent().GearGap)/160000.0)*((1.0-h)*0.5))
	if wlow<-60.0:
		wlow = -60.0
	$wlow.unit_db = wlow
	$wlow.max_db = $wlow.unit_db
	if get_parent().whinepitch/50.0>0.0001:
		$wlow.pitch_scale = get_parent().whinepitch/50.0
	var whigh = linear2db(((get_parent().gearstress*get_parent().GearGap)/80000.0)*0.5)
	if whigh<-60.0:
		whigh = -60.0
	$whigh.unit_db = whigh
	$whigh.max_db = $whigh.unit_db
	if get_parent().whinepitch/100.0>0.0001:
		$whigh.pitch_scale = get_parent().whinepitch/100.0





