extends Control

var car:ViVeCar

func setcar() -> void:
	car = get_parent().get_node(get_parent().car)

func _ready() -> void:
	setcar()
	for i in $scroll/container.get_children():
		if i.var_name == "GEAR_ASSIST":
			i.value = car.GearAssist.assist_level
			i.get_node("amount").text = str(int(i.value))
		else:
			match i.get_class():
				"HSlider":
					i.value = car.car_controls.get(i.var_name)
					i.get_node("amount").text = str(i.value)
				"OptionButton":
					i.select(car.car_controls.control_type)
				"CheckBox":
					i.button_pressed = car.car_controls.get(i.var_name)
					i.get_node("amount").text = str(i.button_pressed)
				_:
					pass

func _process(_delta:float) -> void:
	if not str(get_parent().car) == "":
		for i in $scroll/container.get_children():
			if i.var_name == "GEAR_ASSIST":
				car.GearAssist.assist_level = int(i.value)
				i.get_node("amount").text = str(int(i.value))
			else:
				match  i.get_class():
					"HSlider":
						car.set(i.var_name, i.value)
						i.get_node("amount").text = str(i.value)
					"OptionButton":
						car.car_controls.control_type = i.selected
					"CheckBox":
						car.set(i.var_name,i.button_pressed)
						i.get_node("amount").text = str(i.button_pressed)

func _input(_event:InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		visible = false


func _on_Button_pressed() -> void:
	get_parent().get_node("open controls").release_focus()
	if visible:
		visible = false
	else:
		Input.action_press("ui_cancel")
		await get_tree().create_timer(0.1).timeout
		
		Input.action_release("ui_cancel")
		visible = true
