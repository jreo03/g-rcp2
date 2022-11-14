tool
extends Button

var unfolded = false
var nodes = []
var default_text = ""

func hide_all():
	text = default_text +str(" +")
	unfolded = false

	for i in nodes:
		i.visible = unfolded

func _on_vari_pressed():
	if not unfolded:
		text = default_text +str(" -")
		unfolded = true
	else:
		text = default_text +str(" +")
		unfolded = false

	for i in nodes:
		i.visible = unfolded
		if "nodes" in i:
			i.hide_all()
			for i2 in i.nodes:
				if "nodes" in i2:
					i2.hide_all()
