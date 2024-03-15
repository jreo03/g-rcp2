extends Control

var setup:int = 0

@onready var wheels:Array[ViVeWheel] = [
	get_parent().get_node("fl"),
	get_parent().get_node("fr"),
	get_parent().get_node("rl"),
	get_parent().get_node("rr"),
	
]

func _physics_process(_delta) -> void:
	if setup == 0:
		for i:ViVeWheel in wheels:
			i.get_node("animation/camber/wheel/wheel 1").visible = true
			i.get_node("animation/camber/wheel/wheel 2").visible = false
			i.TyreSettings.GripInfluence = 0.8
			i.TyreSettings.Width_mm = 195.0
			i.TyreSettings.Aspect_Ratio = 40.0
			i.TyreSettings.Rim_Size_in = 18.0
			i.CompoundSettings["ForeFriction"] = 1.0
			if i.name.begins_with("f"):
				i.S_Stiffness = 70.0
				i.S_Damping = 4.0
				i.S_ReboundDamping = 12.0
				i.Camber = 0.0
				i.target_position.y = -3.2
				i.W_PowerBias = 1.0
				i.A_Geometry1 = 1.2
			elif i.name.begins_with("r"):
				i.S_Stiffness = 45.0
				i.S_Damping = 3.0
				i.S_ReboundDamping = 12.0
				i.Camber = 0.0
				i.target_position.y = -3.2
				i.W_PowerBias = 1.0
				i.A_Geometry1 = 1.2
	elif setup == 1:
		for i in wheels:
			i.get_node("animation/camber/wheel/wheel 1").visible = false
			i.get_node("animation/camber/wheel/wheel 2").visible = true
			i.TyreSettings.GripInfluence = 1.0
			i.TyreSettings.Width_mm = 205.0
			i.TyreSettings.Aspect_Ratio = 45.0
			i.TyreSettings.Rim_Size_in = 17.0
			i.CompoundSettings["ForeFriction"] = 0.125
			if i.name.begins_with("f"):
				i.S_Stiffness = 110.0
				i.S_Damping = 6.0
				i.S_ReboundDamping = 12.0
				i.Camber = 0.0
				i.target_position.y = -2.9
				i.W_PowerBias = 0.5
				i.A_Geometry1 = 1.1
			elif i.name.begins_with("r"):
				i.S_Stiffness = 90.0
				i.S_Damping = 5.0
				i.S_ReboundDamping = 12.0
				i.Camber = -1.0
				i.target_position.y = -2.9
				i.W_PowerBias = 1.0
				i.A_Geometry1 = 1.1


func _pressed(extra_arg_0:int) -> void:
	$setup1.release_focus()
	$setup2.release_focus()
	setup = extra_arg_0
