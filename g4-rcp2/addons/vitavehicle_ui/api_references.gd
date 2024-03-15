@tool
extends VBoxContainer

var generated:bool = false

@onready var vari:Button = $vari.duplicate()
@onready var desc:Label = $desc.duplicate()
@onready var type:Label = $type.duplicate()
@onready var cat1:Button = $category1.duplicate()
@onready var cat2:Button = $category2.duplicate()

var controls:Dictionary = {
}
var chassis:Dictionary = {
}
var body:Dictionary = {

}
var steering:Dictionary = {
}

var dt:Dictionary = {
}

var stab:Dictionary = {
}
var diff:Dictionary = {
}
var engine:Dictionary = {
}

var ecu:Dictionary = {
}

var v1:Dictionary = {
}
var v2:Dictionary = {
}
var clutch:Dictionary = {
	"ClutchWobble": ["",0.0],
	"ClutchElasticity": ["",0.0],
	"WobbleRate": ["",0.0],
}

var forced:Dictionary = {
}

var wheel:Dictionary = {
	"A_InclineArea": ["",0.0],
	"A_ImpactForce": ["",0.0],
	"A_Geometry4": ["",0.0],
	"ESP_Role": ["",0.0],
	"ContactBTCS": ["",0.0],
	"ContactTTCS": ["",0.0],
}

var cs:Dictionary = {
	"Stiffness": ["",0.0],
	"DeformFactor": ["",0.0],
	"ForeFriction": ["",0.0],
	"ForeStiffness": ["",0.0],
	"GroundDragAffection": ["",0.0],
}


var tyreset:Dictionary = {
}

func _type(n):
	const builtin_type_names = ["nil", "bool", "int", "float", "string", "vector2", "rect2", "vector3", "maxtrix32", "plane", "quat", "aabb",  "matrix3", "transform", "color", "image", "nodepath", "rid", null, "array", "dictionary", "array", "floatarray", "stringarray", "realarray", "stringarray", "vector2array", "vector3array", "colorarray", "unknown"]
	
	return builtin_type_names[n]

func add(categ:Dictionary, catname:String, descr:String) -> Button:
	var cat:Button = cat2.duplicate()
	add_child(cat)
	cat.text = catname + str(" +")
	cat.default_text = catname
	cat.visible = false
	var desc1 = desc.duplicate()
	add_child(desc1)
	desc1.text = descr
	desc1.visible = false
	cat.nodes.append(desc1)
	for i in categ:
		var v = vari.duplicate()
		add_child(v)
		v.text = i +str(" +")
		var d = desc.duplicate()
		add_child(d)
		d.text = "\n" +str(categ[i][0]) +str("\n")
		var t = type.duplicate()
		add_child(t)
		t.text = "Type: "+str(_type( typeof(categ[i][1]) )) +str("\n")
		v.default_text = i
		v.nodes = [d,t]
		v.visible = false
		d.visible = false
		t.visible = false
		cat.nodes.append(v)
	
	return cat

func generate():
	if not generated:
		$vari.queue_free()
		$desc.queue_free()
		$type.queue_free()
		$category1.queue_free()
		$category2.queue_free()
		
		var car:Button = cat1.duplicate()
		add_child(car)
		car.text = "car.gd +"
		car.default_text = "car.gd"
		car.nodes = [
			add(controls,"Controls", ""),
			add(chassis,"Chassis", ""),
			add(body,"Body", ""),
			add(steering,"Steering", ""),
			add(dt,"Drivetrain", ""),
			add(stab,"Stability (BETA)", ""),
			add(diff,"Differentials", ""),
			add(ecu,"ECU", ""),
			add(v1,"Configuration", ""),
			add(v2,"Configuration VVT","These variables are the second iteration. Vehicles will select these settings when RPMs reach a certain point (VVTRPM), portrayed as Variable Valve Timing."),
			add(clutch,"Clutch (BETA)", ""),
			add(forced,"Forced Inductions (BETA)", ""),
			]
		
		var wheels:Button = cat1.duplicate()
		add_child(wheels)
		wheels.text = "wheel.gd +"
		wheels.default_text = "wheel.gd"
		wheels.nodes = [
			add(wheel,"General", ""),
			add(tyreset,"TyreSettings", ""),
			add(cs,"CompoundSettings", ""),
			]
		
		generated = true
