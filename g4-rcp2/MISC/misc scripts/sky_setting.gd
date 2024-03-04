extends WorldEnvironment

var current_sky = environment
var default_sky = load("res://default_env.tres")

func _process(delta):
	
	if misc_graphics_settings.use_procedual_sky:
		environment = current_sky
	else:
		environment = default_sky
