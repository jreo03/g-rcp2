extends RayCast3D
##A class representing the wheel of a [ViVeCar].
##Each wheel independently calculates its suspension and other values every physics process frame.
class_name ViVeWheel

@export var RealismOptions:Dictionary = {
}
##Allows this wheel to steer.
@export var Steer:bool = true
##Finds a wheel to correct itself to another, in favour of differential mechanics. 
##Both wheels need to have their properties proposed to each other.
@export var Differed_Wheel:NodePath = ""
##Connects a sway bar to the opposing axle. 
##Both wheels should have their properties proposed to each other.
@export var SwayBarConnection:NodePath = ""

##Power Bias (when driven).
@export var W_PowerBias:float = 1.0

@export var TyreSettings:ViVeTyreSettings = ViVeTyreSettings.new()
##Tyre Pressure PSI (hypothetical).
@export var TyrePressure:float = 30.0
##Camber Angle.
@export var Camber:float = 0.0
##Caster Angle.
@export var Caster:float = 0.0
##Toe-in Angle.
@export var Toe:float = 0.0

##Compound settings for tires.
class TyreCompoundSettings:
	extends Resource
	##@experimental Optimum tyre temperature for maximum grip effect. (Currently isn't used).
	@export var OptimumTemp:float = 50.0
	@export var Stiffness:float = 1.0
	##Higher value would reduce grip.
	@export var TractionFactor:float = 1.0
	@export var DeformFactor:float = 1.0
	@export var ForeFriction:float = 0.125
	@export var ForeStiffness:float = 0.0
	@export var GroundDragAffection:float = 1.0
	##Increase in grip on loose surfaces.
	@export var BuildupAffection:float = 1.0
	##@experimental Tyre Cooldown Rate. (Currently isn't used).
	@export var CoolRate:float = 0.000075

#@export var _CompoundSettings:Dictionary = {
#	"OptimumTemp": 50.0,
#	"Stiffness": 1.0,
#	"TractionFactor": 1.0,
#	"DeformFactor": 1.0,
#	"ForeFriction": 0.125,
#	"ForeStiffness": 0.0,
#	"GroundDragAffection": 1.0,
#	"BuildupAffection": 1.0,
#	"CoolRate": 0.000075}

@export var CompoundSettings:TyreCompoundSettings = TyreCompoundSettings.new()
##Spring Force.
@export var S_Stiffness:float = 47.0
##Compression Dampening.
@export var S_Damping:float = 3.5
##Rebound Dampening.
@export var S_ReboundDamping:float = 3.5
##Suspension Deadzone.
@export var S_RestLength:float = 0.0
##Compression Barrier.
@export var S_MaxCompression:float = 0.5
@export var A_InclineArea:float = 0.2
@export var A_ImpactForce:float = 1.5
##Anti-roll Stiffness.
@export var AR_Stiff:float = 0.5
##Anti-roll Reformation Rate.
@export var AR_Elast:float = 0.1
##Brake Force.
@export var B_Torque:float = 15.0
##Brake Bias.
@export var B_Bias:float = 1.0
##
##Leave this at 1.0 unless you have a heavy vehicle with large wheels, set it higher depending on how big it is.
@export var B_Saturation:float = 1.0
##Handbrake Bias.
@export var HB_Bias:float = 0.0
##Axle Vertical Mounting Position.
@export var A_Geometry1:float = 1.15
##Camber Gain Factor.
@export var A_Geometry2:float = 1.0
##Axle lateral mounting position, affecting camber gain. 
##High negative values may mount them outside.
@export var A_Geometry3:float = 0.0

@export var A_Geometry4:float = 0.0

@export var Solidify_Axles:NodePath = NodePath()
##Allows the Anti-lock Braking System to monitor this wheel.
@export var ContactABS:bool = true

@export var ESP_Role:String = ""

@export var ContactBTCS:bool = false

@export var ContactTTCS:bool = false

@onready var car:ViVeCar = get_parent()
@onready var geometry:MeshInstance3D = $"geometry"

@onready var velo_1:Marker3D = $"velocity"
@onready var velo_2:Marker3D = $"velocity2"
@onready var velo_1_step:Marker3D = $"velocity/step"
@onready var velo_2_step:Marker3D = $"velocity2/step"
@onready var anim:Marker3D = $"animation"
@onready var anim_camber:Marker3D = $"animation/camber"
@onready var anim_camber_wheel:Marker3D = $"animation/camber/wheel"

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

var ground_bump:float = 0.0
var ground_bump_up:bool = false
var ground_bump_frequency:float = 0.0

var surface_vars:ViVeSurfaceVars = ViVeSurfaceVars.new()

var hitposition:Vector3 = Vector3(0,0,0)

var cache_tyrestiffness:float = 0.0
var cache_friction_action:float = 0.0

func _ready() -> void:
	c_tp = TyrePressure

func power() -> void:
	if not c_p == 0:
		dist *= pow(car.car_controls.clutchpedal, 2) / (car._currentstable)
		var dist_cache:float = dist
		
		var tol:float = (0.1475 / 1.3558) * car.ClutchGrip
		
		dist_cache = clampf(dist_cache, -tol, tol)
		
		var dist2:float = dist_cache
		
		car._dsweight += c_p
		car._stress += stress * c_p
		
		if car._dsweightrun > 0.0:
			if car._rpm > car.DeadRPM:
				wheelpower -= (((dist2 / car._ds_weight) / (car._dsweightrun / 2.5)) * c_p) / w_weight
			car._resistance += (((dist_cache * (10.0)) / car._dsweightrun) * c_p)

func diffs() -> void:
	if car._locked > 0.0:
		if Differed_Wheel: #Non "" NodePath evaluates true
			var d_w:ViVeWheel = car.get_node(Differed_Wheel)
			snap = absf(d_w.wheelpower_global) / (car._locked * 16.0) + 1.0
			absolute_wv = output_wv+(offset*snap)
			var distanced2:float = absf(absolute_wv - d_w.absolute_wv_diff) / (car._locked * 16.0)
			distanced2 += absf(d_w.wheelpower_global) / (car._locked * 16.0)
			distanced2 = maxf(distanced2, snap)
			
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
	var cast_to:Vector3 = target_position
#	var global_translation:Vector3 = global_position
	var last_translation:Vector3 = position
	
	var x_pos:float = float(translation.x > 0)
	var x_neg:float = float(translation.x < 0)
	
	if Steer and absf(car.car_controls.steer) > 0:
		#var form1 :float = 0.0
		#var form2 :float = car.steering_geometry[1] -translation.x
		var lasttransform:Transform3D = global_transform
		
		look_at_from_position(translation, Vector3(car._steering_geometry[0], 0.0, car._steering_geometry[1]))
		
		
		# just making this use origin fixed it. lol
		global_transform.origin = lasttransform.origin
		
		if car.car_controls.steer > 0.0:
			rotate_object_local(Vector3(0, 1, 0), - deg_to_rad(90.0))
		else:
			rotate_object_local(Vector3(0, 1, 0), deg_to_rad(90.0))
		
		var roter:float = global_rotation.y
		
		look_at_from_position(translation, Vector3(car.Steer_Radius, 0 ,car._steering_geometry[1]))
		
		
		# this one too
		global_transform.origin = lasttransform.origin #This little thing keeps the car from launching into orbit
		
		rotate_object_local(Vector3(0,1,0), deg_to_rad(90.0))
		
		car._steering_angles.append(rad_to_deg(global_rotation.y))
		
		rotation_degrees = Vector3(0, 0, 0)
		rotation = Vector3(0, 0, 0)
		
		rotation.y = roter
		
		rotation_degrees += Vector3(0,- ((Toe * x_pos - Toe * x_neg)),0)
	else:
		rotation_degrees = Vector3(0,- ((Toe * x_pos - Toe * x_neg)),0)
	
	translation = last_translation
	
	c_camber = Camber + Caster * rotation.y * float(translation.x > 0.0) -Caster * rotation.y * float(translation.x < 0.0)
	
	directional_force = Vector3(0,0,0)
	
	velo_1.position = Vector3(0,0,0)
	
	
	#w_size = ((absi(TyreSettings.Width_mm) * ((absi(TyreSettings.Aspect_Ratio) * 2.0) * 0.01) + absi(TyreSettings.Rim_Size_in) * 25.4) * 0.003269) * 0.5
	w_size = ((TyreSettings.Width_mm * ((TyreSettings.Aspect_Ratio * 2.0) * 0.01) + TyreSettings.Rim_Size_in * 25.4) * 0.003269) * 0.5
	w_weight = pow(w_size,2.0)
	
	w_size_read = w_size
	w_size_read = maxf(w_size_read, 1.0)
	w_weight_read = maxf(w_weight_read, 1.0)
	
	velo_2.global_position = geometry.global_position
	
	velo_1_step.global_position = velocity_last
	velo_2_step.global_position = velocity2_last
	velocity_last = velo_1.global_position
	velocity2_last = velo_2.global_position
	
	velocity = -velo_1_step.position * 60.0
	velocity2 = -velo_2_step.position * 60.0
	
	velo_1.rotation = Vector3(0,0,0)
	velo_2.rotation = Vector3(0,0,0)
	
	# VARS
	var elasticity:float = S_Stiffness
	var damping:float = S_Damping
	var damping_rebound:float = S_ReboundDamping
	
	
	rolldist_clamped = clampf(rolldist, -1.0, 1.0)
	
	
	elasticity *= AR_Elast * rolldist_clamped + 1.0
	damping *= AR_Stiff * rolldist_clamped + 1.0
	damping_rebound *= AR_Stiff * rolldist_clamped + 1.0
	
	elasticity = maxf(elasticity, 0.0)
	
	damping = maxf(damping, 0.0)
	
	damping_rebound = maxf(damping_rebound, 0.0)
	
	sway()
	
	var tyre_maxgrip:float = TyreSettings.GripInfluence / CompoundSettings.TractionFactor
	
	#var tyre_stiffness2:float = absi(TyreSettings.Width_mm) / (absi(TyreSettings.Aspect_Ratio) / 1.5)
	var tyre_stiffness2:float = TyreSettings.Width_mm / (TyreSettings.Aspect_Ratio / 1.5)
	
	var deviding:float = (Vector2(velocity.x, velocity.z).length() / 50.0 + 0.5) * CompoundSettings.DeformFactor
	
	deviding /= surface_vars.ground_stiffness + surface_vars.fore_stiffness * CompoundSettings.ForeStiffness
	deviding = maxf(deviding, 1.0)
	
	tyre_stiffness2 /= deviding
	
	
	var tyre_stiffness:float = (tyre_stiffness2 * ((c_tp / 30.0) * 0.1 + 0.9) ) * CompoundSettings.Stiffness + effectiveness
	tyre_stiffness = maxf(tyre_stiffness, 1.0)
	
	cache_tyrestiffness = tyre_stiffness
	
	absolute_wv = output_wv + (offset * snap) - compensate * 1.15296
	absolute_wv_brake = output_wv + ((offset / w_size_read) * snap) - compensate * 1.15296
	absolute_wv_diff = output_wv
	
	wheelpower = 0.0
	
	var braked:float = car._brakeline * B_Bias + car.car_controls.handbrakepull * HB_Bias
	braked = minf(braked, 1.0)
	var bp:float = (B_Torque * braked) / w_weight_read
	
	if not car._actualgear == 0:
		if car._dsweightrun > 0.0:
			bp += ((car._stalled * (c_p / car._ds_weight)) * car.car_controls.clutchpedal) * (((500.0 / (car.RevSpeed * 100.0)) / (car._dsweightrun / 2.5)) / w_weight_read)
	if bp > 0.0:
		if absf(absolute_wv) > 0.0:
			var distanced:float = absf(absolute_wv) / bp
			distanced -= car._brakeline
			distanced = maxf(distanced, snap * (w_size_read / B_Saturation))
			wheelpower += - absolute_wv / distanced
		else:
			wheelpower += -absolute_wv
	
	wheelpower_global = wheelpower
	
	power()
	diffs()
	
	snap = 1.0
	offset = 0.0
	
	# WHEEL
	if is_colliding():
		var collider:Object = get_collider()
		#TEST! Check if it's a ViVeWheel. If it's not, skip the entire stat-sync stuff
		#if collider.is_class("RayCast3D"):
		if "ground_vars" in collider:
			var extern_surf:ViVeSurfaceVars = collider.get("ground_vars")
			surface_vars = extern_surf
			surface_vars.drag = extern_surf.drag * pow(CompoundSettings.GroundDragAffection, 2)
			surface_vars.ground_builduprate = extern_surf.ground_builduprate * CompoundSettings.BuildupAffection
			surface_vars.ground_bump_frequency_random = extern_surf.ground_bump_frequency_random + 1.0
		
		var ground_bump_randi:float = randf_range(ground_bump_frequency / surface_vars.ground_bump_frequency_random, ground_bump_frequency * surface_vars.ground_bump_frequency_random) * (velocity.length() * 0.001)
		
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
		var grip:float = (compress * tyre_maxgrip) * (surface_vars.ground_friction + surface_vars.fore_friction * CompoundSettings.ForeFriction)
		stress = grip
		const rigidity:float = 0.67
		
		#var distw:float = velocity2.z - wv * w_size
		wv += (wheelpower * (1.0 - (1.0 / tyre_stiffness)))
		var disty:float = velocity2.z - wv * w_size
		
		offset = disty / w_size
		
		offset = clampf(offset, -grip, grip)
		
		var distx:float = velocity2.x
		
		var compensate2:float = compress
#		var grav_incline = $geometry.global_transform.basis.orthonormalized().xform_inv(Vector3(0,1,0)).x
		var incline_base:Vector3 = (geometry.global_transform.basis.orthonormalized().transposed() * (Vector3(0,1,0)))
		var grav_incline:float = incline_base.x
#		var grav_incline2 = $geometry.global_transform.basis.orthonormalized().xform_inv(Vector3(0,1,0)).z
		var grav_incline2:float = incline_base.z
		compensate = grav_incline2 * (compensate2 / tyre_stiffness)
		
		distx -= (grav_incline * (compensate2 / tyre_stiffness)) * 1.1
		
		disty *= tyre_stiffness
		#distw *= tyre_stiffness
		distx *= tyre_stiffness
		
		distx -= atan2(absf(wv), 1.0) * ((angle * 10.0) * w_size)
		
		if grip > 0:
			var slip:float = sqrt(pow(absf(disty), 2.0) + pow(absf(distx), 2.0)) / grip
			
			slip_percpre = slip / tyre_stiffness
			
			slip /= slip * surface_vars.ground_builduprate + 1
			slip -= CompoundSettings.TractionFactor
			slip = maxf(slip, 0.0)
			
			var slip_sk:float = sqrt(pow(absf(disty), 2.0) + pow(absf((distx) * 2.0), 2.0)) / grip
			slip_sk /= slip * surface_vars.ground_builduprate + 1
			slip_sk -= CompoundSettings.TractionFactor
			slip_sk = maxf(slip_sk, 0.0)
			
			var slipw:float = sqrt(pow(absf(0.0),2.0) + pow(absf(distx), 2.0)) / grip
			slipw /= slipw * surface_vars.ground_builduprate + 1.0
			var forcey:float = - disty / (slip + 1.0)
			var forcex:float = - distx / (slip + 1.0)
			
			if absf(disty) / (tyre_stiffness / 3.0) > (car.ABS.threshold / grip) * pow(surface_vars.ground_friction, 2) and car.ABS.enabled and abs(velocity.z) > car.ABS.speed_pre_active and ContactABS:
				car._abspump = car.ABS.pump_time
				if absf(distx) / (tyre_stiffness / 3.0) > (car.ABS.lat_thresh / grip) * pow(surface_vars.ground_friction, 2):
					car._abspump = car.ABS.lat_pump_time
			
			var yesx:float =  minf(absf(forcex), 1.0)
			
			var smoothx:float = pow(yesx, 2)
			smoothx = minf(smoothx, 1.0)
			
			var yesy:float = minf(absf(forcey), 1.0)
			
			var smoothy:float = yesy * 1.0
			smoothy = minf(smoothy, 1.0)
			
			forcex /= (smoothx * (rigidity) + (1.0 - rigidity))
			forcey /= (smoothy * (rigidity) + (1.0 - rigidity))
			
			var distyw:float = sqrt(pow(absf(disty), 2.0) + pow(absf(distx), 2.0))
			var tr2:float = (grip / tyre_stiffness)
			var afg:float = tyre_stiffness * tr2
			distyw /= CompoundSettings.TractionFactor
			distyw = maxf(distyw, afg)
			
			var ok:float = ((distyw / tyre_stiffness) / grip) / w_size
			
			ok = minf(ok, 1.0)
			
			snap = ok * w_weight_read
			snap = minf(snap, 1.0)
			
			wv -= forcey * ok
			
			cache_friction_action = forcey * ok
			
			wv += (wheelpower * (1.0 / tyre_stiffness))
			
			rollvol = velocity.length() * grip
			
			sl = slip_sk - tyre_stiffness
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
		var grip:float = (directional_force.y * tyre_maxgrip) * (surface_vars.ground_friction + surface_vars.fore_friction * CompoundSettings.ForeFriction)
		const rigidity:float = 0.67
		#var r:float = 1.0 - rigidity
		
		#var patch_hardness:float = 1.0
		
		
		var disty:float = velocity2.z - (wv * w_size) / (surface_vars.drag + 1.0)
		if  Differed_Wheel: #NodePath will return true if it's not ""
			var d_w:ViVeWheel = car.get_node(Differed_Wheel)
			disty = velocity2.z - ((wv * (1.0 - car._locked) +d_w.wv_diff * car._locked) * w_size) / (surface_vars.drag + 1)
		
		var distx:float = velocity2.x
		
		var compensate2:float = directional_force.y
#		var grav_incline = $geometry.global_transform.basis.orthonormalized().xform_inv(Vector3(0,1,0)).x
		var grav_incline:float = (geometry.global_transform.basis.orthonormalized().transposed() * (Vector3(0,1,0))).x
		
		distx -= (grav_incline * (compensate2 / tyre_stiffness)) * 1.1
		
		slip_perc = Vector2(distx,disty)
		
		disty *= tyre_stiffness
		distx *= tyre_stiffness
	
		distx -= atan2(absf(wv), 1.0) * ((angle * 10.0) * w_size)
		
		if grip > 0:
			var slipraw:float = sqrt(pow(absf(disty), 2.0) + pow(absf(distx), 2.0))
			slipraw = minf(slipraw, grip)
			
			var slip:float = sqrt(pow(absf(disty), 2.0) + pow(absf(distx), 2.0)) / grip
			slip /= slip * surface_vars.ground_builduprate + 1.0
			slip -= CompoundSettings.TractionFactor
			
			slip = maxf(slip, 0)
			
			slip_perc2 = slip
			
			var forcey:float = - disty / (slip + 1.0)
			var forcex:float = - distx / (slip + 1.0)
			
			var yesx:float = minf(absf(forcex), 1.0)
			
			var smoothx:float = pow(yesx, 2)
			smoothx = minf(smoothx, 1.0)
			
			var yesy:float = minf(absf(forcey), 1.0)
			
			var smoothy:float = yesy * 1.0
			smoothy = minf(smoothy, 1.0)
			
			forcex /= (smoothx * (rigidity) + (1.0 - rigidity))
			forcey /= (smoothy * (rigidity) + (1.0 - rigidity))
			
			directional_force.x = forcex
			directional_force.z = forcey
	else:
		geometry.position = target_position
	
	output_wv = wv
	anim_camber_wheel.rotate_x(deg_to_rad(wv))
	
	geometry.position.y += w_size
	var inned:float = (absf(cambered) + A_Geometry4) / 90.0
	
	inned *= inned - A_Geometry4 / 90.0
	geometry.position.x = -inned * translation.x
	anim_camber.rotation.z = - (deg_to_rad(- c_camber * float(translation.x < 0.0) + c_camber * float(translation.x > 0.0)) - deg_to_rad( - cambered * float(translation.x < 0.0) + cambered * float(translation.x > 0.0)) * A_Geometry2)
	var g:float
	
	axle_position = geometry.position.y
	if not Solidify_Axles: #If the NodePath is null
		g = (geometry.position.y + (absf(cast_to.y) - A_Geometry1)) / (absf(translation.x) + A_Geometry3 + 1.0)
		g /= absf(g) + 1.0
		cambered = (g * 90.0) - A_Geometry4
	else:
		g = (geometry.position.y - get_node(Solidify_Axles).axle_position) / (absf(translation.x) + 1.0)
		g /= absf(g) + 1.0
		cambered = (g * 90.0)
	
	anim.position = geometry.position
	
#	var forces = $velocity2.global_transform.basis.orthonormalized().xform(Vector3(0,0,1))*directional_force.z + $velocity2.global_transform.basis.orthonormalized().xform(Vector3(1,0,0))*directional_force.x + $velocity2.global_transform.basis.orthonormalized().xform(Vector3(0,1,0))*directional_force.y
	var forces:Vector3 = (velo_2.global_transform.basis.orthonormalized() * (Vector3(0,0,1))) * directional_force.z + (velo_2.global_transform.basis.orthonormalized() * (Vector3(1,0,0))) * directional_force.x + (velo_2.global_transform.basis.orthonormalized() * (Vector3(0,1,0))) * directional_force.y
	
#	car.apply_impulse(hitposition-car.global_transform.origin,forces)
	car.apply_impulse(forces, hitposition - car.global_transform.origin)
	
	# torque
	
	#var torqed:float = (wheelpower * w_weight) / 4.0
	
	wv_ds = wv
	
#	car.apply_impulse(geometry.global_transform.origin-car.global_transform.origin +$velocity2.global_transform.basis.orthonormalized().xform(Vector3(0,0,1)),$velocity2.global_transform.basis.orthonormalized().xform(Vector3(0,1,0))*torqed)
#	car.apply_impulse(geometry.global_transform.origin-car.global_transform.origin -$velocity2.global_transform.basis.orthonormalized().xform(Vector3(0,0,1)),$velocity2.global_transform.basis.orthonormalized().xform(Vector3(0,1,0))*-torqed)

##Calculate suspension.
func suspension() -> float:
	rolldist_clamped = clampf(rolldist, -1.0, 1.0)
	var g_range:float = absf(target_position.y)
	geometry.global_position = get_collision_point()
	geometry.position.y -= (ground_bump * surface_vars.ground_bump_height)
	
	geometry.position.y = maxf(geometry.position.y, - g_range)
	
	velo_1.global_transform = VitaVehicleSimulation.alignAxisToVector(velo_1.global_transform, get_collision_normal())
	velo_2.global_transform = VitaVehicleSimulation.alignAxisToVector(velo_2.global_transform, get_collision_normal())
	
	var positive_pos:float = float(position.x > 0.0)
	var negative_pos:float = float(position.x < 0.0)
	
	angle = (geometry.rotation_degrees.z - ( - c_camber * positive_pos + c_camber * negative_pos) + ( - cambered * positive_pos + cambered * negative_pos) * A_Geometry2) / 90.0
	
#	var incline = (own.get_collision_normal()-own.global_transform.basis.orthonormalized().xform(Vector3(0,1,0))).length()
	var incline:float = (get_collision_normal() - (global_transform.basis.orthonormalized() * Vector3(0,1,0))).length()
	
	incline /= 1 - A_InclineArea
	
	incline = maxf(incline - A_InclineArea, 0.0)
	
	incline = minf(incline * A_ImpactForce, 1.0)
	
	geometry.position.y = minf(geometry.position.y, - g_range + S_MaxCompression * (1.0 - incline))
	
	var damp_variant:float = S_ReboundDamping * (AR_Stiff * (rolldist_clamped + 1.0))
	
	#linearz = velocity.y
	if velocity.y < 0:
		damp_variant = S_Damping * (AR_Stiff * (rolldist_clamped + 1.0))
	
	
	var compressed:float = g_range - (global_position - get_collision_point()).length() - (ground_bump * surface_vars.ground_bump_height)
	#var compressed2:float = g_range - (global_position - get_collision_point()).length() - (ground_bump * ground_bump_height)
	var compressed2:float = compressed
	compressed2 -= S_MaxCompression + (ground_bump * surface_vars.ground_bump_height)
	
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
	
	return maxf(suspforce, 0.0)
