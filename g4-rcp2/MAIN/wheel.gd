extends RayCast3D
class_name ViVeWheel

@export var RealismOptions:Dictionary = {
}

@export var Steer:bool = true
@export var Differed_Wheel:NodePath = ""
@export var SwayBarConnection:NodePath = ""

@export var W_PowerBias:float = 1.0

@export var TyreSettings:ViVeTyreSettings = ViVeTyreSettings.new()

@export var TyrePressure:float = 30.0
@export var Camber:float = 0.0
@export var Caster:float = 0.0
@export var Toe:float = 0.0

@export var CompoundSettings:Dictionary = {
	"OptimumTemp": 50.0,
	"Stiffness": 1.0,
	"TractionFactor": 1.0,
	"DeformFactor": 1.0,
	"ForeFriction": 0.125,
	"ForeStiffness": 0.0,
	"GroundDragAffection": 1.0,
	"BuildupAffection": 1.0,
	"CoolRate": 0.000075}

@export var S_Stiffness:float = 47.0
@export var S_Damping:float = 3.5
@export var S_ReboundDamping:float = 3.5
@export var S_RestLength:float = 0.0
@export var S_MaxCompression:float = 0.5
@export var A_InclineArea:float = 0.2
@export var A_ImpactForce:float = 1.5
@export var AR_Stiff:float = 0.5
@export var AR_Elast:float = 0.1
@export var B_Torque:float = 15.0
@export var B_Bias:float = 1.0
@export var B_Saturation:float = 1.0 # leave this at 1.0 unless you have a heavy vehicle with large wheels, set it higher depending on how big it is
@export var HB_Bias:float = 0.0
@export var A_Geometry1:float = 1.15
@export var A_Geometry2:float = 1.0
@export var A_Geometry3:float = 0.0
@export var A_Geometry4:float = 0.0
@export var Solidify_Axles:NodePath = NodePath()
@export var ContactABS:bool = true
@export var ESP_Role:String = ""
@export var ContactBTCS:bool = false
@export var ContactTTCS:bool = false

@onready var car:ViVeCar = get_parent()
@onready var geometry:MeshInstance3D = $"geometry"

var dist:float = 0.0
var w_size:float = 1.0
var w_size_read:float = 1.0
var w_weight_read:float = 0.0
var w_weight:float = 0.0
var wv:float = 0.0
var wv_ds:float = 0.0
var wv_diff:float = 0.0
var c_tp:float = 0.0
var effectiveness:float = 0.0

var angle:float = 0.0
var snap:float = 0.0
var absolute_wv:float = 0.0
var absolute_wv_brake:float = 0.0
var absolute_wv_diff:float = 0.0
var output_wv:float = 0.0
var offset:float = 0.0
var c_p:float = 0.0
var wheelpower:float = 0.0
var wheelpower_global:float = 0.0
var stress:float = 0.0
var rolldist:float = 0.0
var rolldist_clamped:float = 0.0
var rd:float = 0.0
var c_camber:float = 0.0
var cambered:float = 0.0

var rollvol:float = 0.0
var sl:float = 0.0
var skvol:float = 0.0
var skvol_d:float = 0.0
var velocity:Vector3 = Vector3(0,0,0)
var velocity2:Vector3 = Vector3(0,0,0)
var compress:float = 0.0
var compensate:float = 0.0
var axle_position:float = 0.0

var heat_rate:float = 1.0
var wear_rate:float = 1.0

var ground_bump:float = 0.0
var ground_bump_up:bool = false
var ground_bump_frequency:float = 0.0
var ground_bump_frequency_random:float = 1.0
var ground_bump_height:float = 0.0

var ground_friction:float = 1.0
var ground_stiffness:float = 1.0
var fore_friction:float = 0.0
var fore_stiffness:float = 0.0
var drag:float = 0.0
var ground_builduprate:float = 0.0
var ground_dirt:bool = false
var hitposition:Vector3 = Vector3(0,0,0)

var cache_tyrestiffness:float = 0.0
var cache_friction_action:float = 0.0

func _ready() -> void:
	c_tp = TyrePressure

func power() -> void:
	if not c_p == 0:
		dist *= (car.clutchpedal * car.clutchpedal) / (car.currentstable)
		var dist_cache:float = dist
		
		var tol:float = (0.1475/1.3558) * car.ClutchGrip
		
		dist_cache = clampf(dist_cache, -tol, tol)
		
		var dist2:float = dist_cache
		
		car.dsweight += c_p
		car.stress += stress * c_p
		
		if car.dsweightrun > 0.0:
			if car.rpm > car.DeadRPM:
				wheelpower -= (((dist2 / car.ds_weight) / (car.dsweightrun / 2.5)) * c_p) / w_weight
			car.resistance += (((dist_cache * (10.0)) / car.dsweightrun) * c_p)

func diffs() -> void:
	if car.locked > 0.0:
		if Differed_Wheel != NodePath(""):
			var d_w:ViVeWheel = car.get_node(Differed_Wheel)
			snap = abs(d_w.wheelpower_global)/(car.locked*16.0) +1.0
			absolute_wv = output_wv+(offset*snap)
			var distanced2:float = abs(absolute_wv - d_w.absolute_wv_diff) / (car.locked * 16.0)
			distanced2 += abs(d_w.wheelpower_global)/(car.locked*16.0)
			if distanced2 < snap:
				distanced2 = snap
			distanced2 += 1.0 / cache_tyrestiffness
			if distanced2 > 0.0:
				wheelpower += -((absolute_wv_diff - d_w.absolute_wv_diff)/distanced2)

func sway() -> void:
	if SwayBarConnection: #NodePath evaluates true when not empty
		var linkedwheel:ViVeWheel = car.get_node(SwayBarConnection)
		rolldist = rd - linkedwheel.rd

var directional_force:Vector3 = Vector3(0,0,0)
var slip_perc:Vector2 = Vector2(0,0)
var slip_perc2:float = 0.0
var slip_percpre:float = 0.0

var velocity_last:Vector3 = Vector3(0,0,0)
var velocity2_last:Vector3 = Vector3(0,0,0)

func _physics_process(_delta:float) -> void:
	var translation:Vector3 = position
	
	var global_translation:Vector3 = global_position
	var last_translation:Vector3 = position
	
	if Steer and absf(car.steer) > 0:
#		var form1 :float = 0.0
#		var form2 :float = car.steering_geometry[1] -translation.x
		var lasttransform:Transform3D = global_transform
		
		look_at_from_position(translation,Vector3(car.steering_geometry[0],0.0,car.steering_geometry[1]))
		
		# just making this use origin fixed it. lol
		global_transform.origin = lasttransform.origin
		
		if car.steer > 0.0:
			rotate_object_local(Vector3(0,1,0),-deg_to_rad(90.0))
		else:
			rotate_object_local(Vector3(0,1,0), deg_to_rad(90.0))
		
		
		look_at_from_position(translation,Vector3(car.Steer_Radius,0,car.steering_geometry[1]),Vector3(0,1,0))
		# this one too
		global_transform.origin = lasttransform.origin
		rotate_object_local(Vector3(0,1,0),deg_to_rad(90.0))
		var roter_estimateed:float = rad_to_deg(global_rotation.y)
		
		get_parent().steering_angles.append(roter_estimateed)
		
		rotation_degrees = Vector3(0,0,0)
		rotation = Vector3(0,0,0)
		
		rotation.y = global_rotation.y
		
		rotation_degrees += Vector3(0,-((Toe*(float(translation.x>0)) -Toe*float(translation.x<0))),0)
	else:
		rotation_degrees = Vector3(0,-((Toe*(float(translation.x>0)) -Toe*float(translation.x<0))),0)
	
	translation = last_translation
	
	c_camber = Camber +Caster*rotation.y*float(translation.x>0.0) -Caster*rotation.y*float(translation.x<0.0)
	
	directional_force = Vector3(0,0,0)
	
	$velocity.position = Vector3(0,0,0)
	
	
	w_size = ((abs(TyreSettings.Width_mm)*((abs(TyreSettings.Aspect_Ratio)*2.0)/100.0) + abs(TyreSettings.Rim_Size_in) * 25.4) * 0.003269) / 2.0
	w_weight = pow(w_size,2.0)
	
	w_size_read = w_size
	if w_size_read < 1.0:
		w_size_read = 1.0
	if w_weight_read < 1.0:
		w_weight_read = 1.0
	
	$velocity2.global_position = geometry.global_position
	
	$velocity/step.global_position = velocity_last
	$velocity2/step.global_position = velocity2_last
	velocity_last = $velocity.global_position
	velocity2_last = $velocity2.global_position
	
	velocity = -$velocity/step.position * 60.0
	velocity2 = -$velocity2/step.position * 60.0
	
	$velocity.rotation = Vector3(0,0,0)
	$velocity2.rotation = Vector3(0,0,0)
	
	# VARS
	var elasticity:float = S_Stiffness
	var damping:float = S_Damping
	var damping_rebound:float = S_ReboundDamping
	
	var swaystiff:float = AR_Stiff
	var swayelast:float = AR_Elast
	
	rolldist_clamped = clampf(rolldist, -1.0, 1.0)
	var s:float = rolldist_clamped
	
	elasticity *= swayelast * s + 1.0
	damping *= swaystiff * s + 1.0
	damping_rebound *= swaystiff * s + 1.0
	
	if elasticity < 0.0:
		elasticity = 0.0
	
	if damping < 0.0:
		damping = 0.0
	
	if damping_rebound < 0.0:
		damping_rebound = 0.0
	
	sway()
	
	var tyre_maxgrip:float = TyreSettings.GripInfluence / CompoundSettings["TractionFactor"]
	
	var tyre_stiffness2:float = abs(TyreSettings.Width_mm) / (abs(TyreSettings.Aspect_Ratio) / 1.5)
	
	var deviding:float = (Vector2(velocity.x,velocity.z).length() / 50.0 + 0.5) * CompoundSettings["DeformFactor"]
	
	deviding /= ground_stiffness + fore_stiffness * CompoundSettings["ForeStiffness"]
	if deviding < 1.0:
		deviding = 1.0
	tyre_stiffness2 /= deviding
	
	
	var tyre_stiffness:float = (tyre_stiffness2 * ((c_tp / 30.0) * 0.1 + 0.9) ) * CompoundSettings["Stiffness"] + effectiveness
	if tyre_stiffness < 1.0:
		tyre_stiffness = 1.0
	
	cache_tyrestiffness = tyre_stiffness
	
	absolute_wv = output_wv+(offset*snap) -compensate*1.15296
	absolute_wv_brake = output_wv+((offset/w_size_read)*snap) -compensate*1.15296
	absolute_wv_diff = output_wv
	
	wheelpower = 0.0
	
	var braked:float = car.brakeline * B_Bias + car.handbrakepull * HB_Bias
	if braked > 1.0:
		braked = 1.0
	var bp:float = (B_Torque * braked) / w_weight_read
	
	if not car.actualgear == 0:
		if car.dsweightrun > 0.0:
			bp += ((car.stalled * (c_p / car.ds_weight)) * car.clutchpedal) * (((500.0 / (car.RevSpeed * 100.0)) / (car.dsweightrun / 2.5)) / w_weight_read)
	if bp > 0.0:
		if abs(absolute_wv) > 0.0:
			var distanced:float = abs(absolute_wv) / bp
			distanced -= car.brakeline
			if distanced < snap * (w_size_read / B_Saturation):
				distanced = snap * (w_size_read / B_Saturation)
			wheelpower += -absolute_wv / distanced
		else:
			wheelpower += -absolute_wv
	
	wheelpower_global = wheelpower
	
	power()
	diffs()
	
	snap = 1.0
	offset = 0.0
	
	# WHEEL
	if is_colliding():
		const loop_collisions:PackedStringArray = [
			"ground_friction", "fore_friction", "ground_stiffness",
			"fore_stiffness", "ground_dirt", "ground_bump_frequency",
			"ground_bump_height", "wear_rate", "heat_rate"
			]
		for checks in loop_collisions:
			if checks in get_collider():
				set(checks, get_collider().get(checks))
		if "drag" in get_collider():
			drag = get_collider().get("drag") * CompoundSettings["GroundDragAffection"] * CompoundSettings["GroundDragAffection"]
		if "ground_builduprate" in get_collider():
			ground_builduprate = get_collider().get("ground_builduprate") * CompoundSettings["BuildupAffection"]
		if "ground_bump_frequency_random" in get_collider():
			ground_bump_frequency_random = get_collider().get("ground_bump_frequency_random") + 1.0
		
		var ground_bump_randi:float = randf_range(ground_bump_frequency / ground_bump_frequency_random, ground_bump_frequency * ground_bump_frequency_random) * (velocity.length() / 1000.0)
		
		if ground_bump_up:
			ground_bump -= ground_bump_randi
			if ground_bump < 0.0:
				ground_bump = 0.0
				ground_bump_up = false
		else:
			ground_bump += ground_bump_randi
			if ground_bump > 1.0:
				ground_bump = 1.0
				ground_bump_up = true
		
		#var suspforce:float = suspension()
		#compress = suspforce
		compress = suspension()
		
		# FRICTION
		var grip:float = (compress * tyre_maxgrip) * (ground_friction + fore_friction * CompoundSettings["ForeFriction"])
		stress = grip
		const rigidity:float = 0.67
		
		var distw:float = velocity2.z - wv * w_size
		wv += (wheelpower * (1.0 - (1.0 / tyre_stiffness)))
		var disty:float = velocity2.z - wv * w_size
		
		offset = disty/w_size
		
		offset = clampf(offset, -grip, grip)
		
		var distx:float = velocity2.x
		
		var compensate2:float = compress
#		var grav_incline = $geometry.global_transform.basis.orthonormalized().xform_inv(Vector3(0,1,0)).x
		var incline_base:Vector3 = ($geometry.global_transform.basis.orthonormalized().transposed() * (Vector3(0,1,0)))
		var grav_incline:float = incline_base.x
#		var grav_incline2 = $geometry.global_transform.basis.orthonormalized().xform_inv(Vector3(0,1,0)).z
		var grav_incline2:float = incline_base.z
		compensate = grav_incline2 * (compensate2 / tyre_stiffness)
		
		distx -= (grav_incline * (compensate2 / tyre_stiffness)) * 1.1
		
		disty *= tyre_stiffness
		distw *= tyre_stiffness
		distx *= tyre_stiffness
		
		distx -= atan2(abs(wv),1.0)*((angle*10.0)*w_size)
		
		if grip > 0:
			
			var slip:float = sqrt(pow(abs(disty), 2.0) + pow(abs(distx), 2.0)) / grip
			
			slip_percpre = slip/tyre_stiffness
			
			slip /= slip*ground_builduprate +1
			slip -= CompoundSettings["TractionFactor"]
			slip = maxf(slip, 0.0)
			
			var slip_sk:float = sqrt(pow(abs(disty), 2.0) + pow(abs((distx) * 2.0), 2.0)) / grip
			slip_sk /= slip * ground_builduprate + 1
			slip_sk -= CompoundSettings["TractionFactor"]
			slip_sk = maxf(slip_sk, 0.0)
			
			var slipw:float = sqrt(pow(abs(0.0),2.0) + pow(abs(distx), 2.0)) / grip
			slipw /= slipw * ground_builduprate + 1.0
			var forcey:float = -disty / (slip + 1.0)
			var forcex:float = -distx / (slip + 1.0)
			
			if abs(disty) / (tyre_stiffness / 3.0) > (car.ABS.threshold / grip) * (ground_friction * ground_friction) and car.ABS.enabled and abs(velocity.z) > car.ABS.speed_pre_active and ContactABS:
				car.abspump = car.ABS.pump_time
				if abs(distx) / (tyre_stiffness/3.0) > (car.ABS.lat_thresh / grip) * (ground_friction * ground_friction):
					car.abspump = car.ABS.lat_pump_time
			
			var yesx:float = abs(forcex)
			yesx = minf(yesx, 1.0)
			
			var smoothx:float = yesx * yesx
			smoothx = minf(smoothx, 1.0)
			
			var yesy:float = abs(forcey)
			yesy = minf(yesy, 1.0)
			
			var smoothy:float = yesy * 1.0
			smoothy = minf(smoothy, 1.0)
			
			forcex /= (smoothx * (rigidity) + (1.0 - rigidity))
			forcey /= (smoothy * (rigidity) + (1.0 - rigidity))
			
			var distyw:float = sqrt(pow(abs(disty), 2.0) + pow(abs(distx), 2.0))
			var tr2:float = (grip / tyre_stiffness)
			var afg:float = tyre_stiffness * tr2
			distyw /= CompoundSettings["TractionFactor"]
			if distyw < afg:
				distyw = afg
			
			var ok:float = ((distyw / tyre_stiffness) / grip) / w_size
			
			ok = minf(ok, 1.0)
			
			snap = ok * w_weight_read
			
			snap = minf(snap, 1.0)
			
			wv -= forcey * ok
			
			cache_friction_action = forcey * ok
			
			wv += (wheelpower * (1.0 / tyre_stiffness))
			
			rollvol = velocity.length() * grip
			
			sl = slip_sk-tyre_stiffness
			sl = maxf(sl, 0.0)
			skvol = sl / 4.0
#			skvol *= skvol
			
			skvol_d = slip * 25.0
	else:
		wv += wheelpower
		stress = 0.0
		rollvol = 0.0
		sl = 0.0
		skvol = 0.0
		skvol_d = 0.0
		compress = 0.0
		compensate = 0.0
	
	slip_perc = Vector2(0,0)
	slip_perc2 = 0.0
	
	wv_diff = wv
	# FORCE
	if is_colliding():
		hitposition = get_collision_point()
		directional_force.y = suspension()
		
		# FRICTION
		var grip:float = (directional_force.y * tyre_maxgrip) * (ground_friction + fore_friction * CompoundSettings["ForeFriction"])
		var rigidity:float = 0.67
		#var r:float = 1.0 - rigidity
		
		#var patch_hardness:float = 1.0
		
		
		var disty:float = velocity2.z - (wv * w_size) / (drag + 1.0)
		if  Differed_Wheel != NodePath(""):
			var d_w:ViVeWheel = car.get_node(Differed_Wheel)
			disty = velocity2.z - ((wv * (1.0 - get_parent().locked) +d_w.wv_diff * get_parent().locked) * w_size) / (drag + 1)
		
		var distx:float = velocity2.x
		
		var compensate2:float = directional_force.y
#		var grav_incline = $geometry.global_transform.basis.orthonormalized().xform_inv(Vector3(0,1,0)).x
		var grav_incline:float = (geometry.global_transform.basis.orthonormalized().transposed() * (Vector3(0,1,0))).x
		
		distx -= (grav_incline*(compensate2/tyre_stiffness))*1.1
		
		slip_perc = Vector2(distx,disty)
		
		disty *= tyre_stiffness
		distx *= tyre_stiffness
	
		distx -= atan2(abs(wv),1.0)*((angle*10.0)*w_size)
		
		if grip > 0:
		
			var slipraw:float = sqrt(pow(abs(disty),2.0) + pow(abs(distx),2.0))
			if slipraw > grip:
				slipraw = grip
				
			var slip:float = sqrt(pow(abs(disty),2.0) + pow(abs(distx),2.0))/grip
			slip /= slip*ground_builduprate +1.0
			slip -= CompoundSettings["TractionFactor"]
			
			slip = maxf(slip, 0)
			
			slip_perc2 = slip
				
			var forcey:float = -disty / (slip + 1.0)
			var forcex:float = -distx / (slip + 1.0)
			
			var yesx:float = abs(forcex)
			yesx = minf(yesx, 1.0)
			
			var smoothx:float = yesx * yesx
			smoothx = minf(smoothx, 1.0)
			
			var yesy:float = abs(forcey)
			yesy = minf(yesy, 1.0)
			
			var smoothy:float = yesy * 1.0
			smoothy = minf(smoothy, 1.0)
			
			forcex /= (smoothx * (rigidity) + (1.0 - rigidity))
			forcey /= (smoothy * (rigidity) + (1.0 - rigidity))
				
			directional_force.x = forcex
			directional_force.z = forcey
	else:
		geometry.position = target_position
	output_wv = wv
	$animation/camber/wheel.rotate_x(deg_to_rad(wv))
	
	geometry.position.y += w_size
	var inned:float = (abs(cambered) + A_Geometry4) / 90.0
	
	inned *= inned -A_Geometry4 / 90.0
	geometry.position.x = -inned*translation.x
	$animation/camber.rotation.z = -(deg_to_rad(-c_camber*float(translation.x<0.0) + c_camber*float(translation.x>0.0)) -deg_to_rad(-cambered*float(translation.x<0.0) + cambered*float(translation.x>0.0))*A_Geometry2)
	var g:float
	
	axle_position = geometry.position.y
	if not Solidify_Axles: #If the NodePath is null
		g = (geometry.position.y + (abs(target_position.y) - A_Geometry1)) / (abs(translation.x) + A_Geometry3 + 1.0)
		g /= abs(g) + 1.0
		cambered = (g * 90.0) - A_Geometry4
	else:
		g = (geometry.position.y - get_node(Solidify_Axles).axle_position) / (abs(translation.x) + 1.0)
		g /= abs(g) + 1.0
		cambered = (g * 90.0)
	
	$animation.position = geometry.position
	
#	var forces = $velocity2.global_transform.basis.orthonormalized().xform(Vector3(0,0,1))*directional_force.z + $velocity2.global_transform.basis.orthonormalized().xform(Vector3(1,0,0))*directional_force.x + $velocity2.global_transform.basis.orthonormalized().xform(Vector3(0,1,0))*directional_force.y
	var forces:Vector3 = ($velocity2.global_transform.basis.orthonormalized() * (Vector3(0,0,1))) * directional_force.z + ($velocity2.global_transform.basis.orthonormalized() * (Vector3(1,0,0))) * directional_force.x + ($velocity2.global_transform.basis.orthonormalized() * (Vector3(0,1,0))) * directional_force.y
	
#	car.apply_impulse(hitposition-car.global_transform.origin,forces)
	car.apply_impulse(forces,hitposition-car.global_transform.origin)
	
	# torque
	
	#var torqed:float = (wheelpower * w_weight) / 4.0
	
	wv_ds = wv
	
#	car.apply_impulse(geometry.global_transform.origin-car.global_transform.origin +$velocity2.global_transform.basis.orthonormalized().xform(Vector3(0,0,1)),$velocity2.global_transform.basis.orthonormalized().xform(Vector3(0,1,0))*torqed)
#	car.apply_impulse(geometry.global_transform.origin-car.global_transform.origin -$velocity2.global_transform.basis.orthonormalized().xform(Vector3(0,0,1)),$velocity2.global_transform.basis.orthonormalized().xform(Vector3(0,1,0))*-torqed)

#VitaVehicleSimulation.suspension(
#			self, #1
#			S_MaxCompression, #2
#			A_InclineArea, #3
#			A_ImpactForce, #4
#			S_RestLength, #5
#			elasticity, #6
#			damping, #7
#			damping_rebound, #8
#			velocity.y, #9
#			abs(target_position.y), #10
#			global_translation, #11
#			get_collision_point(), #12
#			car.mass, #13
#			ground_bump, #14
#			ground_bump_height #15
#			)

func suspension() -> float:
	rolldist_clamped = clampf(rolldist, -1.0, 1.0)
	var g_range:float = abs(target_position.y)
	$geometry.global_position = get_collision_point()
	$geometry.position.y -= (ground_bump * ground_bump_height)
	
	$geometry.position.y = maxf($geometry.position.y, - g_range)
	
	$velocity.global_transform = VitaVehicleSimulation.alignAxisToVector($velocity.global_transform, get_collision_normal())
	$velocity2.global_transform = VitaVehicleSimulation.alignAxisToVector($velocity2.global_transform, get_collision_normal())
	
	var positive_pos:float = float(position.x > 0.0)
	var negative_pos:float = float(position.x < 0.0)
	
	angle = (geometry.rotation_degrees.z - ( -c_camber * positive_pos + c_camber * negative_pos) + ( -cambered * positive_pos + cambered * negative_pos) * A_Geometry2) / 90.0
	
#	var incline = (own.get_collision_normal()-own.global_transform.basis.orthonormalized().xform(Vector3(0,1,0))).length()
	var incline:float = (get_collision_normal() - (global_transform.basis.orthonormalized() * Vector3(0,1,0))).length()
	
	incline /= 1 - A_InclineArea
	
	incline -= A_InclineArea
	
	incline = clampf(incline, 0.0, INF)
	
	incline *= A_ImpactForce
	
	incline = clampf(incline, -INF, 1.0)
	
	geometry.position.y = minf(geometry.position.y, - g_range + S_MaxCompression * (1.0 - incline))
	
	var damp_variant:float = S_ReboundDamping * (AR_Stiff * (rolldist_clamped + 1.0))
	
	#linearz = velocity.y
	if velocity.y < 0:
		damp_variant = S_Damping * (AR_Stiff * (rolldist_clamped + 1.0))
	
	
	var compressed:float = g_range - (global_position - get_collision_point()).length() - (ground_bump * ground_bump_height)
	#var compressed2:float = g_range - (global_position - get_collision_point()).length() - (ground_bump * ground_bump_height)
	var compressed2:float = compressed
	compressed2 -= S_MaxCompression + (ground_bump * ground_bump_height)
	
	var j:float = compressed - S_RestLength
	
	j = maxf(j, 0.0)
	compressed2 = maxf(compressed2, 0.0)
	
	var elasticity2:float = (S_Stiffness * AR_Elast * rolldist_clamped + 1.0) * (1.0 - incline) + (car.mass) * incline
	var damping2:float = damp_variant * (1.0 - incline) + (car.mass / 10.0) * incline
	
	var suspforce:float = j * elasticity2
	
	if compressed2 > 0.0:
		suspforce -= velocity.y * (car.mass / 10.0)
		suspforce += compressed2 * car.mass
	
	suspforce -= velocity.y * damping2
	
	rd = compressed
	
	suspforce = maxf(suspforce, 0.0)
	
	return suspforce
