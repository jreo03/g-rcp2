extends Window

@onready var tabs:TabContainer = $"TabContainer"

var current_tab:int

func check_tab(tab_rn:int) -> void:
	if (tab_rn != current_tab) or (visible == false):
		tabs.current_tab = tab_rn
		current_tab = tab_rn
		show()
	else:
		hide()

func _on_info_pressed() -> void:
	check_tab(0)

func _on_open_graphics_pressed() -> void:
	check_tab(1)

func _on_swap_map_pressed() -> void:
	check_tab(2)


func _on_swap_car_pressed() -> void:
	check_tab(3)

func _on_open_controls_pressed() -> void:
	check_tab(4)

func _on_close_requested() -> void:
	hide()

func _on_tab_container_tab_changed(tab: int) -> void:
	current_tab = tab
