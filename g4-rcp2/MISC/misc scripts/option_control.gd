extends Window


@onready var tabs:TabContainer = $"TabContainer"

func _on_info_pressed() -> void:
	tabs.current_tab = 0
	show()

func _on_open_graphics_pressed() -> void:
	tabs.current_tab = 1
	show()

func _on_swap_map_pressed() -> void:
	tabs.current_tab = 2
	show()

func _on_swap_car_pressed() -> void:
	tabs.current_tab = 3
	show()

func _on_open_controls_pressed() -> void:
	tabs.current_tab = 4
	show()

func _on_close_requested() -> void:
	hide()
