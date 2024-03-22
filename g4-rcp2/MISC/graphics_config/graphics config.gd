extends ScrollContainer

var car:ViVeCar

const default_sky:Environment = preload("res://default_env.tres")

func setcar() -> void:
	car = get_parent().get_node(get_parent().car)

func _ready() -> void:
	for i:CheckBox in $container.get_children():
		i.button_pressed = misc_graphics_settings.get(i.name)

func _on__fullscreen_toggled(toggled_on: bool) -> void:
	if not toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(Vector2i(ProjectSettings.get("display/window/size/viewport_width"),ProjectSettings.get("display/window/size/viewport_height")))
		
		DisplayServer.window_set_position(DisplayServer.screen_get_size()/2 - Vector2i(ProjectSettings.get("display/window/size/viewport_width"),ProjectSettings.get("display/window/size/viewport_height"))/2)
#		DisplayServer.window_borderless = false
#		OS.window_size = Vector2(ProjectSettings.get("display/window/size/width"),ProjectSettings.get("display/window/size/height"))
#		OS.window_position = OS.get_screen_size()/2 -Vector2(ProjectSettings.get("display/window/size/width"),ProjectSettings.get("display/window/size/height"))/2
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		
#		OS.window_borderless = true
#		OS.window_size = OS.get_screen_size()
#		OS.window_size.y += 1
#		OS.window_position = Vector2(0,0)

func _on_tyre_smoke_toggled(toggled_on: bool) -> void:
	misc_graphics_settings.smoke = toggled_on
	VitaVehicleSimulation.misc_smoke = toggled_on

func _on_vsync_toggled(toggled_on: bool) -> void:
	#This setting is a new one added by c08o, mostly for testing
	if toggled_on:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)


func _on_fxaa_toggled(toggled_on: bool) -> void:
	misc_graphics_settings.fxaa = toggled_on
	if toggled_on:
		get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
	else:
		get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED

func _on_shadows_toggled(toggled_on: bool) -> void:
	misc_graphics_settings.shadows = toggled_on
	#I hate this calling, but eh
	ViVeEnvironment.get_singleton().sun.shadow_enabled = toggled_on

func _on_reflections_toggled(toggled_on: bool) -> void:
	misc_graphics_settings.reflections = toggled_on

func _on_use_procedural_sky_toggled(toggled_on: bool) -> void:
	misc_graphics_settings.use_procedural_sky = toggled_on
	ViVeEnvironment.get_singleton().switch_sky(toggled_on)

