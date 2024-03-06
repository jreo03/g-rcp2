extends Node

var reflections :bool = false
var shadows :bool = false
var smoke :bool = false
var fxaa :bool = false
var fs :bool = false

var skytype :int = 0


var fs2 :bool = false

func _process(delta:float) -> void:
#	get_viewport().fxaa = fxaa
	
	if fxaa:
		get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
	else:
		get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
	
	if not fs2 == fs:
		fs2 = fs
		fs_toggle()

func fs_toggle() -> void:
	if not fs:
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
