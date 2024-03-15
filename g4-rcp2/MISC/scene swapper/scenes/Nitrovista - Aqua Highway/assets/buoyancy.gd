extends Area3D


var bodies = []

func _on_Area_body_entered(body):
	if not body in bodies:
		bodies.append(body)

func _on_Area_body_exited(body):
	if not body in bodies:
		bodies.append(body)

func _physics_process(delta):
	for i in bodies:
		if is_instance_valid(i):
			i.linear_velocity /= 1.075
			i.angular_velocity /= 1.075
			var forc = -(i.global_translation.y+60.0)
			if forc<0:
				forc = 0
			i.apply_impulse(Vector3(0,2,0),Vector3(0,forc,0)*10.0)
			if i.global_translation.y>-60.0:
				bodies.remove(bodies.find(i))
		else:
			bodies.remove(bodies.find(i))
