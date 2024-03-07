extends MeshInstance3D

@export var Scale:float = 0.5

func _physics_process(_delta:float) -> void:
	visible = get_parent().get_parent().Debug_Mode
	$compress.visible = get_parent().is_colliding()
	$longi.visible = get_parent().is_colliding()
	$lateral.visible = get_parent().is_colliding()
	
	rotation = get_parent().get_node("velocity").rotation
	
	position = get_parent().get_node("animation").position
	
	position.y -= get_parent().w_size

	$compress.scale = Vector3(0.02,get_parent().directional_force.y*(Scale/1.0),0.02)
	$compress.position.y = $compress.scale.y/2.0
	$longi.scale = Vector3(0.02,0.02,get_parent().directional_force.z*(Scale/1.0))
	$longi.position.z = $longi.scale.z/2.0
	$lateral.scale = Vector3(get_parent().directional_force.x*(Scale/1.0),0.02,0.02)
	$lateral.position.x = $lateral.scale.x/2.0
