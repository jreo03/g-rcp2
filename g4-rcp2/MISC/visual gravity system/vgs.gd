extends Control

class_name ViVeVGS

@export var vgs_scale:float = 1.0
@export var MaxG:float = 0.75

@export var gforce:Vector2 = Vector2(0,0)

@onready var wheel:ViVeDebugWheel = $wheel.duplicate()

var glength:float = 0.0

var appended:Array[ViVeDebugWheel] = []

func _ready() -> void:
	$wheel.queue_free()

func clear() -> void:
	for i:ViVeDebugWheel in appended:
		i.queue_free()
	appended = []


func append_wheel(node:ViVeWheel) -> void:
	var settings:ViVeTyreSettings = node.TyreSettings
	var pos:Vector3 = node.position
	
	var w_size:float = ((abs(settings.Width_mm) * ((abs(settings.Aspect_Ratio) * 2.0) / 100.0) + abs(settings.Rim_Size_in) * 25.4) * 0.003269) / 2.0
	var width:float = (abs(settings.Width_mm) * 0.003269) / 2.0
	
	var w:ViVeDebugWheel = wheel.duplicate()
	add_child(w)
	w.pos = - Vector2(pos.x,pos.z) * 2.0
	w.setting = settings
	w.node = node
	
	w.scale.x = (width * 2.0) / (vgs_scale / 2.0)
	w.scale.y = w_size / (vgs_scale / 2.0)
	
	appended.append(w)

func _physics_process(_delta:float) -> void:
	for i:ViVeDebugWheel in appended:
		if i.node == null:
			continue
		i.position = size * 0.5
		i.position += ((i.pos * (64.0 / vgs_scale)) / 9.806)
		
		i.slippage.scale.y = (i.node.slip_percpre) * 0.8
		
		i.rotation_degrees = - i.node.rotation_degrees.y
		
		i.self_modulate = Color.WHITE
		
		i.slippage.scale.y = clampf(i.slippage.scale.y, 0.0, 0.8)
		if i.slippage.scale.y == 0.8:
			if abs(i.node.wv * i.node.w_size) > i.node.velocity.length():
				i.self_modulate = Color(1,0,0)
			
	
	var vector_cache:float = Vector2(abs(gforce.x), abs(gforce.y)).length()
	#glength = vector_cache / vgs_scale - 1.0
	glength = maxf(vector_cache / vgs_scale - 1.0, 0.0)
	if vector_cache > MaxG:
		$centre/Circle.modulate = Color.KHAKI #Color(1.0, 1.0, 0.5, 1.0)
	else:
		$centre/Circle.modulate = Color.GOLD #Color(1.0, 0.75, 0.0, 1.0)
	
	#glength = maxf(glength, 0.0)
	
	gforce /= glength + 1.0
	
	$centre.position = size / 2 + gforce * (64.0 / vgs_scale)
	$field.position = size / 2
	
