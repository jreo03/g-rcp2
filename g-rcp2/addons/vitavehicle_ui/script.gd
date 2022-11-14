tool
extends EditorPlugin

const MainPanel = preload("res://addons/vitavehicle_ui/interface.tscn")

var undo_redo = get_undo_redo()

var main_panel_instance

static func set_canvas_item_light_mask_value(canvas_item: CanvasItem, layer_number: int, value: bool) -> void:
	assert(layer_number >= 1 and layer_number <= 20, "layer_number must be between 1 and 20 inclusive")
	if value:
		canvas_item.light_mask |= 1 << (layer_number - 1)
	else:
		canvas_item.light_mask &= ~(1 << (layer_number - 1))

func _enter_tree():
	main_panel_instance = MainPanel.instance()
	get_editor_interface().get_editor_viewport().add_child(main_panel_instance)
	make_visible(false)


func _exit_tree():
	if main_panel_instance:
		main_panel_instance.queue_free()


func has_main_screen():
	return true


func make_visible(visible):
	if main_panel_instance:
		main_panel_instance.visible = visible


func get_plugin_name():
	return "VitaVehicle Interface"

func get_plugin_icon():
	# Must return some kind of Texture for the icon.
	return get_editor_interface().get_base_control().get_icon("Node", "EditorIcons")
	
func _unhandled_input(event):
	if event is InputEventKey and event.pressed and event.scancode == KEY_BACKSLASH:
		pass
