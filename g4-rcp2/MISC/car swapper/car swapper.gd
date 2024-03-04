extends Control

@onready var button = $scroll/container/_DEFAULT.duplicate()

var pathh = "res://MISC/car swapper/"
var canclick = true
var literal_cache = {}

func list_files_in_directory(path):
	
	var files = []
#	var dir = Directory.new()
	var dir = DirAccess.open(path)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(file)

	dir.list_dir_end()

	return files
	

func load_and_cache(path):
	var loaded = null
	
	if path in literal_cache:
		pass
	else:
		literal_cache[path] = load(path)

	loaded = literal_cache[path]
	return loaded

@onready var default_position = get_parent().get_parent().get_node("car").global_position

func swapcar(naem):
	visible = false
	get_parent().get_node("swap car").visible = false
	if canclick:
		canclick = false
		get_parent().get_node("vgs").clear()
		
		default_position = get_parent().get_node(get_parent().car).global_position
		
		get_parent().get_node(get_parent().car).queue_free()
		
		get_parent().car = ""
		
		await get_tree().create_timer(1.0).timeout
		
		var d
		
		if naem == "_DEFAULT_CAR_":
			d = load_and_cache("res://base car.tscn").instantiate()
		else:
			d = load_and_cache(pathh+str("cars/")+str(naem)+str("/scene")+str(".tscn")).instantiate()
		
		get_parent().get_parent().add_child(d)
		
		d.global_position = default_position + Vector3(0,5,0)
		
		
		get_parent().car = NodePath("../"+str(d.name))
		
		get_parent()._ready()
		get_parent().get_node("controls manipulator").setcar()
		
		get_parent().get_node("power_graph").Generation_Range = float(int(float(get_parent().get_node(get_parent().car).RPMLimit/1000.0))*1000 +1000)
		get_parent().get_node("power_graph").Draw_RPM = get_parent().get_node(get_parent().car).IdleRPM
		
		get_parent().get_node("power_graph")._ready()
		
		var peak = max(get_parent().get_node("power_graph").peaktq[0],get_parent().get_node("power_graph").peakhp[0])
		
		get_parent().get_node("power_graph").draw_scale = 1.0/peak
		
		get_parent().get_node("power_graph")._ready()
		
		get_parent().get_node("tacho").Redline = int(float(get_parent().get_node(get_parent().car).RPMLimit/1000.0))*1000
		get_parent().get_node("tacho").RPM_Range = int(float(get_parent().get_node(get_parent().car).RPMLimit/1000.0))*1000 +2000
		get_parent().get_node("tacho").Turbo_Visible = get_parent().get_node(get_parent().car).TurboEnabled
		get_parent().get_node("tacho").Max_PSI = get_parent().get_node(get_parent().car).MaxPSI*get_parent().get_node(get_parent().car).TurboAmount
		
		get_parent().get_node("tacho")._ready()
		
		
		canclick = true
	get_parent().get_node("swap car").visible = true


func _ready():
	var d = list_files_in_directory(pathh+str("cars"))
	
	for i in d:
		var but = button.duplicate()
		$scroll/container.add_child(but)
		but.get_node("carname").text = i
		but.get_node("icon").texture = load(pathh+str("cars/")+str(i)+str("/thumbnail")+str(".png"))
#		but.connect("pressed", self, "swapcar",[i])
		but.pressed.connect(swapcar.bind(i))
		
#	$scroll/container/_DEFAULT.connect("pressed", self, "swapcar",["_DEFAULT_CAR_"])
	$scroll/container/_DEFAULT.pressed.connect(swapcar.bind("_DEFAULT_CAR_"))
	

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		visible = false

func _on_swap_car_pressed():
	get_parent().get_node("swap car").release_focus()
	if visible:
		visible = false
	else:
		Input.action_press("ui_cancel")
		await get_tree().create_timer(0.1).timeout
		
		Input.action_release("ui_cancel")
		visible = true


