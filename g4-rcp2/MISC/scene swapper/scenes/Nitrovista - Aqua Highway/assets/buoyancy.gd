extends Area3D


var bodies:Array = []

func _on_Area_body_entered(body) -> void:
	if not body in bodies:
		print(body.get_class())
		bodies.append(body)

func _on_Area_body_exited(body) -> void:
	if not body in bodies:
		bodies.append(body)

func _physics_process(_delta:float) -> void:
	for i in bodies:
		if is_instance_valid(i):
			i.linear_velocity /= 1.075
			i.angular_velocity /= 1.075
			var forc:float = maxf(-(i.global_position.y + 60.0), 0.0)
			i.apply_impulse(Vector3(0, 2, 0), Vector3(0, forc, 0) * 10.0)
			if i.global_position.y > -60.0:
				bodies.remove_at(bodies.find(i))
		else:
			bodies.remove_at(bodies.find(i))
