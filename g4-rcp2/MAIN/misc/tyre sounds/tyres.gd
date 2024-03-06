extends Node3D

var length:float = 0.0
var width:float = 0.0
var weight:float = 0.0
var dirt:float = 0.0

var wheels:Array = []

func play() -> void:
	for i in get_children():
		i.volume_db = linear_to_db(0.0)
		i.play()

func stop() -> void:
	for i in get_children():
		i.stop()

func _ready() -> void:
	for i in get_parent().get_children():
		if "TyreSettings" in i:
			wheels.append(i)
	
	play()

func most_skidding(array:Array):
	var val:float = -10000000000000000000000000000000000.0
	var obj
	
	for i in array:
		val = max(val, abs(i.skvol))
		
		if val == abs(i.skvol):
			obj = i
	
	return obj

func _physics_process(_delta:float) -> void:
	dirt = 0.0
	for i in wheels:
		dirt += float(i.ground_dirt)/len(wheels)
	
	var wheel = most_skidding(wheels)
	
	length = wheel.skvol / 2.0 - 1.0
	
	var roll = abs(wheel.wv * wheel.w_size) - wheel.velocity.length()
	
	if length > 2.0:
		length = 2.0
	
	width -= (width - (1.0 - (roll / 10.0 - 1.0))) * 0.05
	
	width = clampf(width, 0.0, 1.0)
	
	var total:float = 0.0
	
	for i in wheels:
		total += i.skvol
	
	total /= 10.0
	if total > 1.0:
		total = 1.0
	
#	$roll0.pitch_scale = 1.0    /(get_parent().linear_velocity.length()/500.0 +1.0)
	$roll1.pitch_scale = 1.0    /(get_parent().linear_velocity.length()/5000.0 +1.0)
	$roll2.pitch_scale = 1.0    /(get_parent().linear_velocity.length()/5000.0 +1.0)
	$peel0.pitch_scale = 0.95 +length/8.0    /(get_parent().linear_velocity.length()/5000.0 +1.0)
	$peel1.pitch_scale = 1.0    /(get_parent().linear_velocity.length()/5000.0 +1.0)
	$peel2.pitch_scale = 1.1 -total*0.1    /(get_parent().linear_velocity.length()/5000.0 +1.0)
	
	var drit:float = (get_parent().linear_velocity.length()*wheel.stress) / 1000.0 - 0.1
	if drit > 0.5:
		drit = 0.5
	
	drit += wheel.skvol / 2.0 - 0.1
	
	drit = clampf(drit, 0.0, 1.0)
	
	drit *= dirt
	
	for i in get_children():
		if i.name == "dirt":
			i.volume_db = linear_to_db(drit * 0.3)
			i.max_db = i.volume_db
			i.pitch_scale = 1.0 + length * 0.05 + abs( roll / 100.0)
		else:
			var dist:float = abs(i.length - length)
			var dist2:float = abs(i.width - width)
			
			dist *= abs(dist)
			dist2 *= abs(dist2)
			
			var vol:float = 1.0 - (dist + dist2)
			vol = clampf(vol, 0.0, 1.0)
			i.volume_db = linear_to_db(((vol * (1.0 - dirt)) * i.volume) * 0.35)
			i.max_db = i.volume_db
