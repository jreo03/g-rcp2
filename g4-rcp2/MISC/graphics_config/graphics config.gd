extends ScrollContainer

var car:ViVeCar

func setcar() -> void:
	car = get_parent().get_node(get_parent().car)

func _ready() -> void:
	for i:CheckBox in $container.get_children():
		i.button_pressed = misc_graphics_settings.get(i.var_name)
		i.get_node("amount").text = str(i.button_pressed)

func _process(_delta:float) -> void:
	for i in $container.get_children():
		misc_graphics_settings.set(i.var_name,i.button_pressed)
		i.get_node("amount").text = str(i.button_pressed)

func _input(_event:InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		visible = false
	elif Input.is_action_just_pressed("toggle_fs"):
		$container/_FULLSCREEN.button_pressed = !$container/_FULLSCREEN.button_pressed
		
#		if $scroll/container/_FULLSCREEN.button_pressed:
#			$scroll/container/_FULLSCREEN.button_pressed = false
#		else:
#			$scroll/container/_FULLSCREEN.button_pressed = true


func _on_Button_pressed() -> void:
	get_parent().get_node("open graphics").release_focus()
	if visible:
		visible = false
	else:
		Input.action_press("ui_cancel")
		await get_tree().create_timer(0.1).timeout
		Input.action_release("ui_cancel")
		visible = true
