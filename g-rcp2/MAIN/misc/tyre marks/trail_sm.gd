extends Spatial

var last_pos = transform
var g = Vector3(0,0,0)

var vertices = []

var del = 0

var wid = 0.125

var ran = false

var inserting = false
var inserting2 = false

var current_trail = null
var drawers = []

func add_segment():
	var ppos = global_transform
	
	vertices.append( [
		
		ppos.origin + ppos.basis.orthonormalized().xform(Vector3(wid,0,0)),
		ppos.origin - ppos.basis.orthonormalized().xform(Vector3(wid,0,0)),

		ppos.origin,
		] )

	last_pos = ppos

func _physics_process(delta):
	
#	get_parent().get_node("Camera").rotation_degrees.y += 20
	
	del -= 1
	
	for i in drawers:
		i.delete_wait -= 1
		if i.delete_wait<0:
			if current_trail == i:
				current_trail = null
			i.queue_free()
			drawers.remove(0)

	if del<0 and inserting:
		del = 5
		add_segment()

func _process(_delta):
	
	inserting = get_parent().get_parent().slip_perc.length()>get_parent().get_parent().stress +20.0 and get_parent().get_parent().is_colliding()
	
	translation.y = -get_parent().get_parent().w_size +0.025
	wid = get_parent().get_parent().TyreSettings["Width (mm)"]/750.0
	
	if not inserting2 == inserting:
		inserting2 = inserting
		if inserting2:

			if not current_trail == null:
				var t = current_trail.global_transform
				remove_child(current_trail)
				get_tree().get_current_scene().add_child(current_trail)
				current_trail.global_transform = t

			vertices.clear()
			current_trail = $trail.duplicate()
			add_child(current_trail)
			drawers.append(current_trail)


	ran = true
	if (global_transform.origin - g).length()>0.1:
		look_at(g,Vector3(0,1,0))

	g = global_transform.origin
	var ppos = global_transform
	
	if not current_trail == null:
		if inserting:
			current_trail.delete_wait = 180
			if len(vertices)>0:
				vertices[len(vertices)-1][0] = (ppos.origin + ppos.basis.orthonormalized().xform(Vector3(wid,0,0)))
				vertices[len(vertices)-1][1] = (ppos.origin - ppos.basis.orthonormalized().xform(Vector3(wid,0,0)))
				vertices[len(vertices)-1][2] = ppos.origin

		current_trail.global_transform.basis = get_tree().get_current_scene().global_transform.basis
		current_trail.clear()
		current_trail.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
		for i in vertices:
			if len(i)>0:
				current_trail.add_vertex(i[0] -global_transform.origin)
				current_trail.add_vertex(i[1] -global_transform.origin)
			
		current_trail.end()

