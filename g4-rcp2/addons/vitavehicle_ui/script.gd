@tool
extends EditorPlugin

#const MainPanel:PackedScene = preload("res://addons/vitavehicle_ui/interface.tscn")
const GraphPanel:PackedScene = preload("res://addons/vitavehicle_ui/portable_graph/power_graph_ui.tscn")

var undo_redo:EditorUndoRedoManager = get_undo_redo()

#var main_panel_instance:Control
var graph_panel_instance:Control

var graph_button:Button

func _init() -> void:
	var car_script:Script = load("res://MAIN/car.gd")
	var logo:Texture2D = load("res://vlogo.png")
	add_custom_type("ViVeCar", "RigidBody3D", car_script, logo)

#static func set_canvas_item_light_mask_value(canvas_item: CanvasItem, layer_number: int, value: bool) -> void:
#	assert(layer_number >= 1 and layer_number <= 20, "layer_number must be between 1 and 20 inclusive")
#	if value:
#		canvas_item.light_mask |= 1 << (layer_number - 1)
#	else:
#		canvas_item.light_mask &= ~(1 << (layer_number - 1))

func _enable_plugin() -> void:
	initalize()

func _enter_tree() -> void:
	initalize()

func initalize() -> void:
	#main_panel_instance = MainPanel.instantiate()
	graph_panel_instance = GraphPanel.instantiate()
	#EditorInterface.get_editor_main_screen().add_child(main_panel_instance)
	graph_button = add_control_to_bottom_panel(graph_panel_instance, "Torque Graph")

func _disable_plugin() -> void:
	deinitalize()

func _exit_tree() -> void:
	deinitalize()

func deinitalize() -> void:
#	if main_panel_instance:
#		main_panel_instance.queue_free()
	remove_control_from_bottom_panel(graph_panel_instance)
	remove_custom_type("ViVeCar")

func _has_main_screen() -> bool:
	return true

#func _make_visible(visible:bool) -> void:
#	if main_panel_instance:
#		main_panel_instance.visible = visible

func _get_plugin_name() -> String:
	return "VitaVehicle Interface"

func _get_plugin_icon() -> Texture2D:
	# Must return some kind of Texture for the icon.
	return EditorInterface.get_base_control().get_theme_icon("Node", "EditorIcons")

#func _unhandled_input(event:InputEvent) -> void:
#	if event is InputEventKey and event.pressed and event.scancode == KEY_BACKSLASH:
#	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_BACKSLASH:
#		pass
