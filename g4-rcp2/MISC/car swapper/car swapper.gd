extends ScrollContainer

@onready var button:Button = $container/_DEFAULT.duplicate()

const pathh:String = "res://MISC/car swapper/"
var canclick:bool = true
var literal_cache:Dictionary = {}

func list_files_in_directory(path:String) -> PackedStringArray:
	
	var files:PackedStringArray = []
#	var dir = Directory.new()
	var dir:DirAccess = DirAccess.open(path)
	dir.list_dir_begin()
	
	while true:
		var file:String = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(file)
	
	dir.list_dir_end()
	
	return files

func load_and_cache(path:String) -> PackedScene:
	var loaded:PackedScene = null
	
	if path in literal_cache:
		pass
	else:
		literal_cache[path] = load(path)
	
	loaded = literal_cache[path]
	return loaded

@onready var default_position:Vector3 = get_tree().current_scene.get_node("car").global_position


func swapcar(naem:String) -> void:
	#get_parent().get_node("swap car").visible = false
	if canclick:
		canclick = false
		
		#TODO: reimplement
		#get_parent().get_node("vgs").clear()
		
		#default_position = get_parent().get_node(get_parent().car).global_position
		default_position = ViVeEnvironment.singleton.car.global_position
		
		ViVeEnvironment.singleton.car.queue_free()
		
		await get_tree().create_timer(1.0).timeout
		
		var d:Node
		
		
		if naem == "_DEFAULT_CAR_":
			d = load_and_cache("res://base car.tscn").instantiate()
		else:
			d = load_and_cache(pathh + "cars/"+ naem + "/scene.tscn").instantiate()
		
		ViVeEnvironment.singleton.add_child(d)
		ViVeEnvironment.singleton.car = d
		
		d.global_position = default_position + Vector3(0,5,0)
		
		var debug_child:Control = ViVeDebug.singleton.get_node("tacho")
		
		debug_child.Redline = int(float(d.RPMLimit / 1000.0)) * 1000
		debug_child.RPM_Range = int(float(d.RPMLimit / 1000.0)) * 1000 + 2000
		debug_child.Turbo_Visible = d.TurboEnabled
		debug_child.Max_PSI = d.MaxPSI * d.TurboAmount
		
		debug_child._ready()
		
		
		canclick = true
#	get_parent().get_node("swap car").visible = true

func _ready() -> void:
	var d:PackedStringArray = list_files_in_directory(pathh + "cars")
	
	for i:String in d:
		var but:Button = button.duplicate()
		$container.add_child(but)
		but.get_node("carname").text = i
		but.get_node("icon").texture = load(pathh + "cars/" + i + "/thumbnail.png")
#		but.connect("pressed", self, "swapcar",[i])
		but.pressed.connect(swapcar.bind(i))
	
#	$scroll/container/_DEFAULT.connect("pressed", self, "swapcar",["_DEFAULT_CAR_"])
	$container/_DEFAULT.pressed.connect(swapcar.bind("_DEFAULT_CAR_"))
