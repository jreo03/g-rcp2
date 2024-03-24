extends ScrollContainer

var car:ViVeCar

func setcar() -> void:
	car = ViVeEnvironment.singleton.car
	ViVeCarControlOption.control_ref = car.car_controls

func _ready() -> void:
	ViVeEnvironment.singleton.connect("ready", setup)
	ViVeEnvironment.singleton.connect("car_changed", setcar)

func setup() -> void:
	setcar()
	for i in $container.get_children():
		match i.get_class():
			"HSlider":
				if i.treat_as_int:
					#Currently, and only because of this one exception, 
					# this works. But this should be changed in the future.
					i.value = car.GearAssist.get(i.var_name)
					i.get_node("amount").text = str(int(i.value))
				else:
					i.value = car.car_controls.get(i.var_name)
					i.get_node("amount").text = str(i.value)
			"OptionButton":
				i.select(car.car_controls.control_type)
			"CheckBox":
				i.button_pressed = car.car_controls.get(i.var_name)
				i.get_node("amount").text = str(i.button_pressed)
			_:
				pass
