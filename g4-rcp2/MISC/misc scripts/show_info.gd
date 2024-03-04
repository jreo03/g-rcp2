extends Control

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		visible = false

func _on_info_pressed():
	get_parent().get_node("info").release_focus()
	if visible:
		visible = false
	else:
		Input.action_press("ui_cancel")
		await get_tree().create_timer(0.1).timeout
		Input.action_release("ui_cancel")
		visible = true
