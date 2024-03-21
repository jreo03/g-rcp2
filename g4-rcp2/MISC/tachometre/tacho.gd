extends Control

class_name ViVeTachometer

var currentrpm :float = 0.0
var currentpsi :float = 0.0

@export var Turbo_Visible :bool = false
@export var Max_PSI :float = 13.0
@export var RPM_Range :float = 9000.0
@export var Redline :float = 7000.0

var generated:Array[ColorRect] = []

@onready var turbo_needle:TextureRect = $"turbo/needle"

@onready var tacho_needle:TextureRect = $"tacho/needle"

func _ready() -> void:
	var turbo:TextureRect = $"turbo"
	turbo.visible = Turbo_Visible
	var turbo_max:Label = $"turbo/maxpsi"
	turbo_max.text = str(int(Max_PSI))
	if len(generated) > 0:
		for i:ColorRect in generated:
			i.queue_free()
		generated.clear()
	
	var lowangle:int = -120
	var highangle:int = 120
	
	var maximum:int = int(RPM_Range / 1000.0)
	var red:float = Redline / 1000.0 - 0.001
	
	for i:int in range(maximum + 1):
		var dist:float = float(i) / float(maximum)
		var dist2:float = (float(i) + 0.25) / float(maximum)
		var dist3:float = (float(i) + 0.5) / float(maximum)
		var dist4:float = (float(i) + 0.75) / float(maximum)
		
		var d:ColorRect = $tacho/major.duplicate(true)
		$tacho.add_child(d)
		d.rotation_degrees = lowangle * (1.0-dist) + highangle * dist
		d.visible = true
		var tetx:Label = d.get_node("tetx")
		tetx.text = str(i)
		tetx.rotation_degrees = -d.rotation_degrees
		generated.append(d)
		
		if float(i) > red:
			d.color = Color(1,0,0)
		
		if len(tetx.text) > 1:
			tetx.position.y += 5
		
		if not i == maximum:
			d = $tacho/minor.duplicate(true)
			$tacho.add_child(d)
			d.rotation_degrees = lowangle*(1.0-dist2) + highangle*dist2
			d.visible = true
			generated.append(d)
			if float(i + 0.25) > red:
				d.color = Color.RED
			
			d = $tacho/minor.duplicate(true)
			$tacho.add_child(d)
			d.rotation_degrees = lowangle * (1.0 - dist3) + highangle * dist3
			d.visible = true
			generated.append(d)
			if float(i + 0.5) > red:
				d.color = Color.RED
			
			d = $tacho/minor.duplicate(true)
			$tacho.add_child(d)
			d.rotation_degrees = lowangle * (1.0 - dist4) + highangle * dist4
			d.visible = true
			generated.append(d)
			if float(i + 0.75) > red:
				d.color = Color.RED

func _process(_delta:float) -> void:
	tacho_needle.rotation_degrees = - 120.0 + 240.0 * (absf(currentrpm) / RPM_Range)
	
	turbo_needle.rotation_degrees = - 90.0 + 180.0 * (currentpsi / Max_PSI)
	
	turbo_needle.rotation_degrees = maxf(turbo_needle.rotation_degrees, - 90.0)
#	if $turbo/needle.rotation_degrees < - 90.0:
#		$turbo/needle.rotation_degrees = - 90.0
