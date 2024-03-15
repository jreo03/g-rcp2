extends ReflectionProbe


func _process(delta):
	global_position = get_viewport().get_camera_3d().global_position
	global_position.y = -get_viewport().get_camera_3d().global_position.y -50.0
	
	
	visible = misc_graphics_settings.reflections
