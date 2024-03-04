extends TouchScreenButton

@onready var default_pos = position/get_parent().base_resolution
@onready var default_size = scale/get_parent().base_resolution


func _process(delta):
#	position = default_pos*OS.get_real_window_size()
	position = default_pos * Vector2(DisplayServer.window_get_size_with_decorations())
#	scale = default_size*OS.get_real_window_size()
	scale = default_size * Vector2(DisplayServer.window_get_size_with_decorations())


func press(state):
	if state:
		Input.action_press(name)
	else:
		Input.action_release(name)
