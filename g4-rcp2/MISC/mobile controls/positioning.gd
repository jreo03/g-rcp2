extends TouchScreenButton

@onready var default_pos:Vector2 = position / get_parent().base_resolution
@onready var default_size:Vector2 = scale / get_parent().base_resolution

func _ready() -> void:
	position = default_pos * Vector2(DisplayServer.window_get_size_with_decorations())
	scale = default_size * Vector2(DisplayServer.window_get_size_with_decorations())

func _process(_delta:float) -> void:
#	position = default_pos*OS.get_real_window_size()
	#position = default_pos * Vector2(DisplayServer.window_get_size_with_decorations())
#	scale = default_size*OS.get_real_window_size()
	#scale = default_size * Vector2(DisplayServer.window_get_size_with_decorations())
	return


func press(state:bool) -> void:
	if state:
		Input.action_press(action)
	else:
		Input.action_release(action)
