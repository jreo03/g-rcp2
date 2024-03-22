extends WorldEnvironment

var current_sky:Environment = environment
const default_sky:Environment = preload("res://default_env.tres")

#This is one of those process frames that is wasteful
func _process(_delta) -> void:
	if misc_graphics_settings.use_procedural_sky:
		environment = current_sky
	else:
		environment = default_sky
