extends Spatial

var length = 0.0
var width = 0.0
var weight = 0.0
var dirt = 0.0

var wheels = []

func play():
	for i in get_children():
		i.unit_db = linear2db(0.0)
		i.play()
		
func stop():
	for i in get_children():
		i.stop()

func _ready():
	for i in get_parent().get_children():
		if "TyreSettings" in i:
			wheels.append(i)
	
	play()
	
func most_skidding(array):
	var val = -10000000000000000000000000000000000.0
	var obj
	
	for i in array:
		val = max(val, abs(i.skvol))
		
		if val == abs(i.skvol):
			obj = i

	return obj

func _physics_process(delta):
	dirt = 0.0
	for i in wheels:
		dirt += float(i.ground_dirt)/len(wheels)
	
	var wheel = most_skidding(wheels)
	
	length = wheel.skvol/2.0 -1.0
	
	var roll = abs(wheel.wv*wheel.w_size) - wheel.velocity.length()
	
	if length>2.0:
		length = 2.0

	width -= (width - (1.0 -(roll/10.0 -1.0)))*0.05

	if width>1.0:
		width = 1.0
	elif width<0.0:
		width = 0.0
		
	var total = 0.0

	for i in wheels:
		total += i.skvol

	total /= 10.0
	if total>1.0:
		total = 1.0

#	$roll0.pitch_scale = 1.0    /(get_parent().linear_velocity.length()/500.0 +1.0)
	$roll1.pitch_scale = 1.0    /(get_parent().linear_velocity.length()/5000.0 +1.0)
	$roll2.pitch_scale = 1.0    /(get_parent().linear_velocity.length()/5000.0 +1.0)
	$peel0.pitch_scale = 0.95 +length/8.0    /(get_parent().linear_velocity.length()/5000.0 +1.0)
	$peel1.pitch_scale = 1.0    /(get_parent().linear_velocity.length()/5000.0 +1.0)
	$peel2.pitch_scale = 1.1 -total*0.1    /(get_parent().linear_velocity.length()/5000.0 +1.0)
	
	var drit = (get_parent().linear_velocity.length()*wheel.stress)/1000.0 -0.1
	if drit>0.5:
		drit = 0.5

	drit += wheel.skvol/2.0 -0.1

	if drit>1.0:
		drit = 1.0
	elif drit<0.0:
		drit = 0.0
	
	drit *= dirt
	
	for i in get_children():
		if i.name == "dirt":
			i.unit_db = linear2db(drit*0.3)
			i.max_db = i.unit_db
			i.pitch_scale = 1.0 +length*0.05 +abs(roll/100.0)
		else:
			var dist = abs(i.length -length)
			
			var dist2 = abs(i.width -width)

			dist *= abs(dist)
			dist2 *= abs(dist2)
			
			var vol = 1.0-(dist + dist2)
			if vol<0.0:
				vol = 0.0
			elif vol>1.0:
				vol = 1.0
			i.unit_db = linear2db(((vol*(1.0-dirt))*i.volume)*0.35)
			i.max_db = i.unit_db
