extends WorldEnvironment

var current_sky:Environment = environment
var default_sky:Environment = load("res://default_env.tres")

func _process(_delta) -> void:
	if misc_graphics_settings.use_procedual_sky:
		environment = current_sky
	else:
		environment = default_sky
