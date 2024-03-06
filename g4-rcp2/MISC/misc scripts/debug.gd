extends Control
class_name ViVeDebug

var changed_graph_size:Vector2 = Vector2(0,0)
@export var car :NodePath = NodePath("../car")

func _ready() -> void:
	if not str(car) == "":
		$vgs.clear()
		for d in get_node(car).get_children():
			if "TyreSettings" in d:
				$vgs.append_wheel(d.position,d.TyreSettings,d)
		for i in $power_graph.get_script().get_script_property_list():
			if not i["name"] == "peakhp" and not i["name"] == "tr" and not i["name"] == "tr" and not i["name"] == "hp" and not i["name"] == "skip" and not i["name"] == "scale":
				if i["name"] in get_node(car):
					$power_graph.set(i["name"], get_node(car).get(i["name"]))

func _process(delta:float) -> void:
	VitaVehicleSimulation.misc_smoke = misc_graphics_settings.smoke
	if delta > 0:
		get_node("container/fps").text = "fps: "+str(1.0 / delta)
		if has_node(car):
			$sw.rotation_degrees = get_node(car).steer * 380.0
			$sw_desired.rotation_degrees = get_node(car).steer2 * 380.0
			if get_node(car).Debug_Mode:
				get_node("container/weight_dist").text = "weight distribution: F%f/R%f" % [get_node(car).weight_dist[0] * 100,get_node(car).weight_dist[1] * 100]
			else:
				get_node("container/weight_dist").text = "[ enable Debug_Mode or press F to\nfetch weight distribution ]"

	if not changed_graph_size == $power_graph.size:
		changed_graph_size = $power_graph.size
		$power_graph._ready()
		
		
	if not str(car) == "":
		
		$"fix engine".visible = get_node(car).rpm<get_node(car).DeadRPM
		
		$throttle.bar_scale = get_node(car).gaspedal
		$brake.bar_scale = get_node(car).brakepedal
		$handbrake.bar_scale = get_node(car).handbrakepull
		$clutch.bar_scale = get_node(car).clutchpedalreal
		
		$tacho/speedk.text = "KM/PH: " +str(int(get_node(car).linear_velocity.length()*1.10130592))
		$tacho/speedm.text = "MPH: " +str(int((get_node(car).linear_velocity.length()*1.10130592)/1.609 ) )
		
		
		
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

		$power_graph/rpm.position.x = (get_node(car).rpm/$power_graph.Generation_Range)*$power_graph.size.x -1.0
		$power_graph/redline.position.x = (get_node(car).RPMLimit/$power_graph.Generation_Range)*$power_graph.size.x -1.0

		$g.text = "Gs:\nx%s,\ny%s,\nz%s" % [str(int(get_node(car).gforce.x*100.0)/100.0),str(int(get_node(car).gforce.y*100.0)/100.0),str(int(get_node(car).gforce.z*100.0)/100.0)]

		$tacho.currentpsi = get_node(car).turbopsi*(get_node(car).TurboAmount)
		$tacho.currentrpm = get_node(car).rpm
		$tacho/rpm.text = str(int(get_node(car).rpm))
		
		if get_node(car).rpm < 0:
			$tacho/rpm.self_modulate = Color(1,0,0)
		else:
			$tacho/rpm.self_modulate = Color(1,1,1)
		
		if get_node(car).gear == 0:
			$tacho/gear.text = "N"
		elif get_node(car).gear == -1:
			$tacho/gear.text = "R"
		else:
			if get_node(car).TransmissionType == 1 or get_node(car).TransmissionType == 2:
				$tacho/gear.text = "D"
			else:
				$tacho/gear.text = str(get_node(car).gear)

func _physics_process(_delta:float) -> void:
	if not str(car) == "":
		$vgs.gforce -= ($vgs.gforce - Vector2(get_node(car).gforce.x,get_node(car).gforce.z))*0.5
		
		$tacho/abs.visible = get_node(car).abspump>0 and get_node(car).brakepedal>0.1
		$tacho/tcs.visible = get_node(car).tcsflash
		$tacho/esp.visible = get_node(car).espflash

func engine_restart() -> void:
	if has_node(car):
		get_node(car).rpm = get_node(car).IdleRPM

func toggle_forces() -> void:
	Input.action_press("toggle_debug_mode")
