extends Control
##A class representing the root of the in-game debug panel.
class_name ViVeDebug

##The debug panel singleton
static var singleton:ViVeDebug = null

var changed_graph_size:Vector2 = Vector2(0,0)

@onready var car_node:ViVeCar

@onready var tacho_gear:Label = $tacho/gear

@onready var tacho_rpm:Label = $tacho/rpm

@onready var power_graph:Control = $power_graph

@onready var vgs:ViVeVGS = $vgs

func _ready() -> void:
	if not ViVeEnvironment.singleton.is_connected("ready", setup):
		ViVeEnvironment.singleton.connect("ready", setup)
	if not ViVeEnvironment.singleton.is_connected("car_changed", update_car):
		ViVeEnvironment.singleton.connect("car_changed", update_car)
	singleton = self

func update_car() -> void:
	car_node = ViVeEnvironment.singleton.car

#This is signal-ified due to being "too early" when done in _ready()
func setup() -> void:
	update_car()
	vgs.clear()
	for d:ViVeWheel in car_node.get_wheels():
		vgs.append_wheel(d)
	
	#What in the world-
	
#	for i:Dictionary in $power_graph.get_script().get_script_property_list():
#		print(i)
#		const blacklist:PackedStringArray = ["peakhp", "tr", "hp", "skip", "scale"]
#		#if not i["name"] == "peakhp" and not i["name"] == "tr" and not i["name"] == "tr" and not i["name"] == "hp" and not i["name"] == "skip" and not i["name"] == "scale":
#		if not blacklist.has(i.get("name")):
#			if i["name"] in car_node:
#				$power_graph.set(i["name"], car_node.get(i["name"]))

func _process(delta:float) -> void:
	if car_node == null:
		return
	VitaVehicleSimulation.misc_smoke = misc_graphics_settings.smoke
	if delta > 0:
		#str(Performance.get_monitor(Performance.TIME_FPS))
		$container/fps.text = "fps: " + str(1.0 / delta)
		
		$sw.rotation_degrees = car_node.car_controls.steer * 380.0
		$sw_desired.rotation_degrees = car_node.car_controls.steer2 * 380.0
		if car_node.Debug_Mode:
			$container/weight_dist.text = "weight distribution: F%f/R%f" % [car_node.weight_dist[0] * 100, car_node.weight_dist[1] * 100]
		else:
			$container/weight_dist.text = "[ enable Debug_Mode or press F to\nfetch weight distribution ]"
	
	if not changed_graph_size == power_graph.size:
		changed_graph_size = power_graph.size
		power_graph._ready()
	
	$"fix engine".visible = car_node._rpm < car_node.DeadRPM
	
	$throttle.bar_scale = car_node.car_controls.gaspedal
	$brake.bar_scale = car_node.car_controls.brakepedal
	$handbrake.bar_scale = car_node.car_controls.handbrakepull
	$clutch.bar_scale = car_node._clutchpedalreal
	
	$tacho/speedk.text = "KM/PH: " +str(int(car_node.linear_velocity.length() * 1.10130592))
	$tacho/speedm.text = "MPH: " +str(int((car_node.linear_velocity.length() * 1.10130592) / 1.609 ) )
	
	var hpunit:String = "hp"
	
	match power_graph.Power_Unit:
		1:
			hpunit = "bhp"
		2:
			hpunit = "ps"
		3:
			hpunit = "kW"
		_:
			pass
	
	$hp.text = "Power: %s%s @ %s RPM" % [str( int(power_graph.peakhp[0] * 10.0) / 10.0 ), hpunit, str(int(power_graph.peakhp[1] * 10.0) / 10.0)]
	
	var tqunit:String = "ft⋅lb"
	if power_graph.Torque_Unit == 1:
		tqunit = "nm"
	elif power_graph.Torque_Unit == 2:
		tqunit = "kg/m"
	$tq.text = "Torque: %s%s @ %s RPM" % [str(int(power_graph.peaktq[0] * 10.0) / 10.0 ), tqunit, str(int(power_graph.peaktq[1] * 10.0) / 10.0)]
	
	$power_graph/rpm.position.x = (car_node._rpm/power_graph.Generation_Range) * power_graph.size.x - 1.0
	$power_graph/redline.position.x = (car_node.RPMLimit/power_graph.Generation_Range) * power_graph.size.x - 1.0
	
	$g.text = "Gs:\nx%s,\ny%s,\nz%s" % [str(int(car_node._gforce.x * 100.0) / 100.0), str(int(car_node._gforce.y * 100.0) / 100.0), str(int(car_node._gforce.z * 100.0) / 100.0)]
	
	$tacho.currentpsi = car_node._turbopsi * (car_node.TurboAmount)
	$tacho.currentrpm = car_node._rpm
	tacho_rpm.text = str(int(car_node._rpm))
	
	if car_node._rpm < 0:
		tacho_rpm.self_modulate = Color(1,0,0)
	else:
		tacho_rpm.self_modulate = Color(1,1,1)
	
	if car_node.car_controls.gear == 0:
		tacho_gear.text = "N"
	elif car_node.car_controls.gear == -1:
		tacho_gear.text = "R"
	else:
		if car_node.TransmissionType == 1 or car_node.TransmissionType == 2:
			tacho_gear.text = "D"
		else:
			tacho_gear.text = str(car_node.car_controls.gear)

func _physics_process(_delta:float) -> void:
	if car_node == null:
		return
	vgs.gforce -= (vgs.gforce - Vector2(car_node._gforce.x, car_node._gforce.z)) * 0.5
	
	$tacho/abs.visible = car_node._abspump > 0 and car_node.car_controls.brakepedal > 0.1
	$tacho/tcs.visible = car_node._tcsflash
	$tacho/esp.visible = car_node._espflash

##Restarts the car's engine. Needed if the RPM dips to low and it stalls.
func engine_restart() -> void:
	if car_node != null:
		car_node._rpm = car_node.IdleRPM

func toggle_forces() -> void:
	Input.action_press("toggle_debug_mode")



