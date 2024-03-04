extends Control

@onready var button = $scroll/container/_DEFAULT.duplicate()

var pathh = "res://MISC/scene swapper/"
var canclick = true
var literal_cache = {}

@export var current_map = NodePath()

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

func swapmap(naem):
	visible = false
	get_node(current_map).queue_free()
	
	var d = load_and_cache(pathh+str("scenes/")+str(naem)+str("/scene")+str(".tscn")).instantiate()
	
	get_parent().get_parent().add_child(d)
	
	current_map = "../../"+str(d.name)
	
	await get_tree().create_timer(0.1).timeout
	get_parent().get_node(get_parent().car).global_position *= 0
	get_parent().get_node(get_parent().car).global_rotation *= 0
	get_parent().get_node(get_parent().car).linear_velocity *= 0
	get_parent().get_node(get_parent().car).angular_velocity *= 0


func _ready():
	$scroll/container/_DEFAULT.queue_free()
	
	
	var d = list_files_in_directory(pathh+str("scenes"))
	
	for i in d:
		var but = button.duplicate()
		$scroll/container.add_child(but)
		but.get_node("mapname").text = i
		but.get_node("icon").texture = load(pathh+str("scenes/")+str(i)+str("/thumbnail")+str(".png"))
#		but.connect("pressed", self, "swapmap",[i])
		but.pressed.connect(swapmap.bind(i))
	

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		visible = false

func _on_swap_map_pressed():
	get_parent().get_node("swap map").release_focus()
	if visible:
		visible = false
	else:
		Input.action_press("ui_cancel")
		await get_tree().create_timer(0.1).timeout
		Input.action_release("ui_cancel")
		visible = true

