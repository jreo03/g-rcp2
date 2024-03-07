extends Control
class_name ViVeDebug

var changed_graph_size:Vector2 = Vector2(0,0)
@export var car:NodePath = NodePath("../car")
@onready var car_node:ViVeCar 

func _ready() -> void:
	if not str(car) == "":
		car_node = get_node(car)
		$vgs.clear()
		for d:ViVeWheel in car_node.get_wheels():
			$vgs.append_wheel(d.position,d.TyreSettings,d)
		#What in the world-
		for i:Dictionary in $power_graph.get_script().get_script_property_list():
			const blacklist:PackedStringArray = ["peakhp", "tr", "hp", "skip", "scale"]
			#if not i["name"] == "peakhp" and not i["name"] == "tr" and not i["name"] == "tr" and not i["name"] == "hp" and not i["name"] == "skip" and not i["name"] == "scale":
			if not blacklist.has(i.get("name")):
				if i["name"] in car_node:
					$power_graph.set(i["name"], car_node.get(i["name"]))


func _process(delta:float) -> void:
	VitaVehicleSimulation.misc_smoke = misc_graphics_settings.smoke
	if delta > 0:
		get_node("container/fps").text = "fps: "+ str(1.0 / delta)
		$sw.rotation_degrees = car_node.steer * 380.0
		$sw_desired.rotation_degrees = car_node.steer2 * 380.0
		if car_node.Debug_Mode:
			get_node("container/weight_dist").text = "weight distribution: F%f/R%f" % [car_node.weight_dist[0] * 100, car_node.weight_dist[1] * 100]
		else:
			get_node("container/weight_dist").text = "[ enable Debug_Mode or press F to\nfetch weight distribution ]"
	
	if not changed_graph_size == $power_graph.size:
		changed_graph_size = $power_graph.size
		$power_graph._ready()
		
		
	if not str(car) == "":
		
		$"fix engine".visible = car_node.rpm < car_node.DeadRPM
		
		$throttle.bar_scale = car_node.gaspedal
		$brake.bar_scale = car_node.brakepedal
		$handbrake.bar_scale = car_node.handbrakepull
		$clutch.bar_scale = car_node.clutchpedalreal
		
		$tacho/speedk.text = "KM/PH: " +str(int(car_node.linear_velocity.length() * 1.10130592))
		$tacho/speedm.text = "MPH: " +str(int((car_node.linear_velocity.length() * 1.10130592) / 1.609 ) )
		
		
		
		var hpunit:String = "hp"
		if $power_graph.Power_Unit == 1:
			hpunit = "bhp"
		elif $power_graph.Power_Unit == 2:
			hpunit = "ps"
		elif $power_graph.Power_Unit == 3:
			hpunit = "kW"
		$hp.text = "Power: %s%s @ %s RPM" % [str( int($power_graph.peakhp[0]*10.0)/10.0 ), hpunit ,str( int($power_graph.peakhp[1]*10.0)/10.0 )]

		var tqunit:String = "ft⋅lb"
		if $power_graph.Torque_Unit == 1:
			tqunit = "nm"
		elif $power_graph.Torque_Unit == 2:
			tqunit = "kg/m"
		$tq.text = "Torque: %s%s @ %s RPM" % [str( int($power_graph.peaktq[0]*10.0)/10.0 ), tqunit ,str( int($power_graph.peaktq[1]*10.0)/10.0 )]

		$power_graph/rpm.position.x = (car_node.rpm/$power_graph.Generation_Range)*$power_graph.size.x -1.0
		$power_graph/redline.position.x = (car_node.RPMLimit/$power_graph.Generation_Range)*$power_graph.size.x -1.0

		$g.text = "Gs:\nx%s,\ny%s,\nz%s" % [str(int(car_node.gforce.x * 100.0) / 100.0),str(int(car_node.gforce.y * 100.0) / 100.0),str(int(car_node.gforce.z * 100.0) / 100.0)]

		$tacho.currentpsi = car_node.turbopsi * (car_node.TurboAmount)
		$tacho.currentrpm = car_node.rpm
		$tacho/rpm.text = str(int(car_node.rpm))
		
		if car_node.rpm < 0:
			$tacho/rpm.self_modulate = Color(1,0,0)
		else:
			$tacho/rpm.self_modulate = Color(1,1,1)
		
		if car_node.gear == 0:
			$tacho/gear.text = "N"
		elif car_node.gear == -1:
			$tacho/gear.text = "R"
		else:
			if car_node.TransmissionType == 1 or car_node.TransmissionType == 2:
				$tacho/gear.text = "D"
			else:
				$tacho/gear.text = str(car_node.gear)

func _physics_process(_delta:float) -> void:
	if not str(car) == "":
		$vgs.gforce -= ($vgs.gforce - Vector2(car_node.gforce.x,car_node.gforce.z)) * 0.5
		
		$tacho/abs.visible = car_node.abspump > 0 and car_node.brakepedal > 0.1
		$tacho/tcs.visible = car_node.tcsflash
		$tacho/esp.visible = car_node.espflash

func engine_restart() -> void:
	car_node.rpm = car_node.IdleRPM
#	if has_node(car):
#		get_node(car).rpm = get_node(car).IdleRPM

func toggle_forces() -> void:
	Input.action_press("toggle_debug_mode")
