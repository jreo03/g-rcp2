@tool
extends TabContainer
var engine_enabled:bool = false

var ed:EditorPlugin = EditorPlugin.new()

var undo_redo:UndoRedo = UndoRedo.new()

var eds:EditorSelection = EditorInterface.get_selection()

@onready var power_graph:ViVeTorqueGraph = $"Engine_Tuner/power_graph"
@onready var tune_vars:VBoxContainer = $"Engine_Tuner/tune/container"
@onready var tune_alert:AcceptDialog = $"Engine_Tuner/alert"
@onready var tune_confirm:ConfirmationDialog = $"Engine_Tuner/confirm"
@onready var tune_confirm_append:ConfirmationDialog = $"Engine_Tuner/confirm_append"

var changed_graph_size:Vector2 = Vector2(0.0, 0.0)

var nods_buffer:Array[Node] = []

func press(state:String) -> void:
	tune_alert.dialog_text = ""
	tune_alert.position.y = int(size.y / 2.0 + tune_alert.size.y / 2.0)
	tune_alert.size = Vector2(83,58)

	tune_confirm.dialog_text = ""
	tune_confirm.position.y = int(size.y / 2.0 + tune_confirm.size.y / 2.0)
	tune_confirm.size = Vector2(83,58)
	
	tune_confirm_append.dialog_text = ""
	tune_confirm_append.position.y = int(size.y / 2.0 + tune_confirm_append.size.y / 2.0)
	tune_confirm_append.size = Vector2(83, 58)
	
	if state == "unit_tq":
		power_graph.Torque_Unit += 1
		if power_graph.Torque_Unit > 2:
			power_graph.Torque_Unit = 0
		power_graph.draw_graph()
	elif state == "unit_hp":
		power_graph.Power_Unit += 1
		if power_graph.Power_Unit > 3:
			power_graph.Power_Unit = 0
		power_graph.draw_graph()
	
	elif state == "engine":
		current_tab = 0
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
	elif state == "discord":
		var _err:Error = OS.shell_open("https://discord.gg/kCvNBujcfR")
	elif state == "itch.io":
		var _err:Error = OS.shell_open("https://jreo.itch.io/rcp4/community")
#	elif state == "collide_apply":
#		if len(eds.get_selected_nodes()) == 0:
#			$Collision/nothing.popup()
#		else:
#			$Collision/alert.popup()
#			for i in eds.get_selected_nodes():
#				var arrays = i.shape.points
#				for g in arrays:
#					arrays.set(arrays.find(g), g * Vector3($Collision/axis_x2.value,$Collision/axis_y2.value,$Collision/axis_z2.value) + Vector3($Collision/axis_x.value,$Collision/axis_y.value, $Collision/axis_z.value) )
#				i.shape.set_points(arrays)
#			
#			$Collision/alert.visible = false
#			$Collision/applied.popup()

#func confirm(state:String) -> void:
#	if state == "engine_apply":
#		for i in tune_vars.get_children():
#			for n:Node in nods_buffer:
#				if i.get_class() == "SpinBox":
#					n.set(i.var_name,float(i.value))
#				elif i.get_class() == "CheckBox":
#					n.set(i.var_name,i.button_pressed)
#	elif state == "engine_append":
#		for i in tune_vars.get_children():
#			for n:Node in nods_buffer:
#				if i.get_class() == "SpinBox":
#					i.value = float(n.get(i.var_name))
#				elif i.get_class() == "CheckBox":
#					i.button_pressed = n.get(i.var_name)

func _on_info_pressed() -> void:
	set_current_tab(4)

func _on_history_pressed() -> void:
	pass # Replace with function body.


func _on_help_pressed() -> void:
	pass # Replace with function body.


func _on_api_pressed() -> void:
	pass # Replace with function body.
