@tool
extends TabContainer
var engine_enabled:bool = false

var ed:EditorPlugin = EditorPlugin.new()

var undo_redo:UndoRedo = UndoRedo.new()

var eds:EditorSelection = ed.get_editor_interface().get_selection()

func entered_engine():
	for i in $Engine_Tuner/tune/container.get_children():
		if i.get_class() == "CheckBox":
			i.button_pressed = $Engine_Tuner/power_graph.car.get(str(i.var_name))
		elif i.get_class() == "SpinBox":
			i.value = $Engine_Tuner/power_graph.car.get(i.var_name)
		if i.get_node("varname").text == "":
			i.get_node("varname").text = i.var_name
	refresh()

func refresh():
	$Engine_Tuner/power_graph.car.Draw_RPM = $Engine_Tuner/power_graph.car.IdleRPM
	$Engine_Tuner/power_graph.car.Generation_Range = $Engine_Tuner/power_graph.car.RPMLimit
	$Engine_Tuner/power_graph.draw_()
	var peak = max($Engine_Tuner/power_graph.peaktq[0],$Engine_Tuner/power_graph.peakhp[0])
	if peak > 0:
		$Engine_Tuner/power_graph.graph_scale = 1.0 / peak
	$Engine_Tuner/power_graph.draw_()
	
	var hpunit:String = "hp"
	if $Engine_Tuner/power_graph.Power_Unit == 1:
		hpunit = "bhp"
	elif $Engine_Tuner/power_graph.Power_Unit == 2:
		hpunit = "ps"
	elif $Engine_Tuner/power_graph.Power_Unit == 3:
		hpunit = "kW"
	$Engine_Tuner/hp.text = "Power: %s%s @ %s RPM" % [str( int($Engine_Tuner/power_graph.peakhp[0]*10.0)/10.0 ), hpunit ,str( int($Engine_Tuner/power_graph.peakhp[1]*10.0)/10.0 )]
	
	var tqunit:String = "ft⋅lb"
	if $Engine_Tuner/power_graph.Torque_Unit == 1:
		tqunit = "nm"
	elif $Engine_Tuner/power_graph.Torque_Unit == 2:
		tqunit = "kg/m"
	$Engine_Tuner/tq.text = "Torque: %s%s @ %s RPM" % [str( int($Engine_Tuner/power_graph.peaktq[0]*10.0)/10.0 ), tqunit ,str( int($Engine_Tuner/power_graph.peaktq[1]*10.0)/10.0 )]

var changed_graph_size:Vector2 = Vector2(0.0,0.0)

func _process(_delta) -> void:
#	if not changed_graph_size == $Engine_Tuner/power_graph.size and engine_enabled:
#		changed_graph_size = $Engine_Tuner/power_graph.size
#		$Engine_Tuner/power_graph.draw_()
	
	if engine_enabled:
		for i in $Engine_Tuner/tune/container.get_children():
			if i.get_class() == "SpinBox":
				if not $Engine_Tuner/power_graph.get(i.var_name) == float(i.value):
					$Engine_Tuner/power_graph.set(i.var_name, float(i.value))
					refresh()
			elif i.get_class() == "CheckBox":
#				print(i)
#				print(i.var_name)
				if not $Engine_Tuner/power_graph.get(str(i.var_name)) == i.button_pressed:
					$Engine_Tuner/power_graph.set(i.var_name, i.button_pressed)
					refresh()

var nods_buffer:Array[Node] = []

func press(state:String) -> void:
	$Engine_Tuner/alert.dialog_text = ""
	$Engine_Tuner/alert.position.y = size.y/2.0 +$Engine_Tuner/alert.size.y / 2.0
	$Engine_Tuner/alert.size = Vector2(83,58)

	$Engine_Tuner/confirm.dialog_text = ""
	$Engine_Tuner/confirm.position.y = size.y/2.0 +$Engine_Tuner/confirm.size.y/2.0
	$Engine_Tuner/confirm.size = Vector2(83,58)
	
	$Engine_Tuner/confirm_append.dialog_text = ""
	$Engine_Tuner/confirm_append.position.y = size.y/2.0 +$Engine_Tuner/confirm_append.size.y/2.0
	$Engine_Tuner/confirm_append.size = Vector2(83,58)
	
	if state == "unit_tq":
		$Engine_Tuner/power_graph.Torque_Unit += 1
		if $Engine_Tuner/power_graph.Torque_Unit > 2:
			$Engine_Tuner/power_graph.Torque_Unit = 0
		$Engine_Tuner/power_graph.draw_()
		refresh()
	elif state == "unit_hp":
		$Engine_Tuner/power_graph.Power_Unit += 1
		if $Engine_Tuner/power_graph.Power_Unit > 3:
			$Engine_Tuner/power_graph.Power_Unit = 0
		$Engine_Tuner/power_graph.draw_()
		refresh()
	
	elif state == "engine":
		current_tab = 0
		entered_engine()
		engine_enabled = true
	elif state == "weight_dist":
		current_tab = 1
	elif state == "info":
		current_tab = 4
	elif state == "help":
		current_tab = 2
	elif state == "api":
		current_tab = 4
	elif state == "back":
		current_tab = 3
	elif state == "engine_apply":
		nods_buffer = eds.get_selected_nodes().duplicate(true)
		var missing:PackedStringArray = []
		var nods:Array[Node] = eds.get_selected_nodes()
		if len(eds.get_selected_nodes()) == 0:
			$Engine_Tuner/alert.dialog_text = "Nothing is selected."
			$Engine_Tuner/alert.popup()
		else:
			missing = []
			if len(eds.get_selected_nodes()) == 1:
				$Engine_Tuner/alert.dialog_text = "This node is missing these variables: \n"
				for i in $Engine_Tuner/tune/container.get_children():
					if not i.var_name in nods[0]:
						$Engine_Tuner/alert.dialog_text += str("-") +str(i.var_name) +str("\n")
						missing.append(i.var_name)
			else:
				$Engine_Tuner/alert.dialog_text = "One or more nodes are missing certain variables."
				for i in $Engine_Tuner/tune/container.get_children():
					for i_nods in nods:
						if not i.var_name in i_nods:
							missing.append(i.var_name)
			
			$Engine_Tuner/confirm.dialog_text = "This configuration will be applied to the following nodes: \n"
			for i in nods:
				$Engine_Tuner/confirm.dialog_text += str("-") +str(i.name) +str("\n")
			
			
			if len(missing) == 0:
				$Engine_Tuner/confirm.popup()
			else:
				$Engine_Tuner/alert.popup()
	
	elif state == "engine_append":
		nods_buffer = eds.get_selected_nodes().duplicate(true)
		var missing:PackedStringArray = []
		var nods = eds.get_selected_nodes()
		if len(eds.get_selected_nodes()) == 0:
			$Engine_Tuner/alert.dialog_text = "Nothing is selected."
			$Engine_Tuner/alert.popup()
		else:
			missing = []
			if len(eds.get_selected_nodes()) == 1:
				$Engine_Tuner/alert.dialog_text = "This node is missing these variables: \n"
				for i in $Engine_Tuner/tune/container.get_children():
					if not i.var_name in nods[0]:
						$Engine_Tuner/alert.dialog_text += str("-") +str(i.var_name) +str("\n")
						missing.append(i.var_name)
				if len(missing) == 0:
					$Engine_Tuner/confirm_append.dialog_text = "You are importing the configurations from: " +str(nods[0].name)
					$Engine_Tuner/confirm_append.popup()
				else:
					$Engine_Tuner/alert.popup()
			else:
				$Engine_Tuner/alert.dialog_text = "You can only append from one node."
				$Engine_Tuner/alert.popup()
	elif state == "discord":
		OS.shell_open("https://discord.gg/kCvNBujcfR")
	elif state == "itch.io":
		OS.shell_open("https://jreo.itch.io/rcp4/community")
	elif state == "collide_apply":
		if len(eds.get_selected_nodes()) == 0:
			$Collision/nothing.popup()
		else:
			$Collision/alert.popup()
			for i in eds.get_selected_nodes():
				var arrays = i.shape.points
				for g in arrays:
					arrays.set(arrays.find(g),g*Vector3($Collision/axis_x2.value,$Collision/axis_y2.value,$Collision/axis_z2.value) +Vector3($Collision/axis_x.value,$Collision/axis_y.value,$Collision/axis_z.value) )
				i.shape.set_points(arrays)
			
			$Collision/alert.visible = false
			$Collision/applied.popup()

func confirm(state:String) -> void:
	if state == "engine_apply":
		for i in $Engine_Tuner/tune/container.get_children():
			for n in nods_buffer:
				if i.get_class() == "SpinBox":
					n.set(i.var_name,float(i.value))
				elif i.get_class() == "CheckBox":
					n.set(i.var_name,i.button_pressed)
	elif state == "engine_append":
		for i in $Engine_Tuner/tune/container.get_children():
			for n in nods_buffer:
				if i.get_class() == "SpinBox":
					i.value = float(n.get(i.var_name))
				elif i.get_class() == "CheckBox":
					i.button_pressed = n.get(i.var_name)

func _on_info_pressed() -> void:
	set_current_tab(4)



func _on_history_pressed() -> void:
	pass # Replace with function body.


func _on_help_pressed() -> void:
	pass # Replace with function body.


func _on_api_pressed() -> void:
	pass # Replace with function body.
