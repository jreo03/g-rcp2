extends MeshInstance


export var Scale = 0.5

func _physics_process(delta):
	visible = get_parent().get_parent().Debug_Mode
	$compress.visible = get_parent().is_colliding()
	$longi.visible = get_parent().is_colliding()
	$lateral.visible = get_parent().is_colliding()
	
	rotation = get_parent().get_node("velocity").rotation
	
	translation = get_parent().get_node("animation").translation
	
	translation.y -= get_parent().w_size

	$compress.scale = Vector3(0.02,get_parent().directional_force.y*(Scale/1.0),0.02)
	$compress.translation.y = $compress.scale.y/2.0
	$longi.scale = Vector3(0.02,0.02,get_parent().directional_force.z*(Scale/1.0))
	$longi.translation.z = $longi.scale.z/2.0
	$lateral.scale = Vector3(get_parent().directional_force.x*(Scale/1.0),0.02,0.02)
	$lateral.translation.x = $lateral.scale.x/2.0
