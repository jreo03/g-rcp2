extends Node3D

var last_pos:Transform3D = transform
var g:Vector3 = Vector3(0,0,0)

var vertices:Array[Basis] = []

var del:int = 0

var wid:float = 0.125

var ran:bool = false

var inserting:bool = false
var inserting2:bool = false

var current_trail_node:ViVeWheelMark = null
var current_trail :ImmediateMesh = null
var drawers:Array[MeshInstance3D] = []

var wheel_parent:ViVeWheel

# i spent 5 days trying to figure out why the skids were not working properly
	# the immediate mesh resource was shared between all the skids :/
	# ok i just do this on line 82


func add_segment() -> void:
	var ppos:Transform3D = global_transform
	var new_basis:Basis
	new_basis.x = ppos.origin + (ppos.basis.orthonormalized() * Vector3(wid, 0, 0))
	new_basis.y = ppos.origin - (ppos.basis.orthonormalized() * Vector3(wid,0,0))
	new_basis.z = ppos.origin
#	vertices.append( [
#		ppos.origin + (ppos.basis.orthonormalized() * Vector3(wid,0,0)),
#		ppos.origin - (ppos.basis.orthonormalized() * Vector3(wid,0,0)),
#		
#		ppos.origin,
#		] )
	vertices.append(new_basis)
	last_pos = ppos


func _physics_process(_delta:float) -> void:
	
#	get_parent().get_node("Camera").rotation_degrees.y += 20
	
	del -= 1
	
	for i:ViVeWheelMark in drawers:
		i.delete_wait -= 1
		if i.delete_wait < 0:
			if current_trail == i:
				current_trail = null
			i.queue_free()
			drawers.remove_at(0)
	
	if del < 0 and inserting:
		del = 5
		add_segment()


func _process(_delta:float) -> void:
	wheel_parent = get_parent().get_parent()
	
	inserting = wheel_parent.slip_perc.length() > wheel_parent.stress + 20.0 and wheel_parent.is_colliding()
	
	position.y = -wheel_parent.w_size + 0.025
	wid = wheel_parent.TyreSettings.Width_mm / 750.0
	
	if not inserting2 == inserting:
		inserting2 = inserting
		if inserting2:
			
			if not current_trail_node == null:
				var t:Transform3D = current_trail_node.global_transform
				remove_child(current_trail_node)
				get_tree().get_current_scene().add_child(current_trail_node)
				current_trail_node.global_transform = t
			
			vertices.clear()
			current_trail_node = $trail.duplicate()
			# we changed our node so we need to update our resource too.
			# not sure if i should use new resource or use a copy of the old one
			# but im not noticing any difference by using a new one, soo...
			current_trail_node.mesh = ImmediateMesh.new()
			current_trail = current_trail_node.mesh
			
			add_child(current_trail_node)
			drawers.append(current_trail_node)
	
	
	ran = true
	if (global_transform.origin - g).length_squared() > 0.01:
		look_at(g,Vector3(0, 1, 0))
	
	g = global_transform.origin
	var ppos:Transform3D = global_transform
	
	if not current_trail_node == null:
		if inserting:
			current_trail_node.delete_wait = 180
			if len(vertices) > 0:
				vertices[len(vertices) - 1][0] = ((ppos.origin + ppos.basis.orthonormalized() * Vector3(wid, 0, 0)))
				vertices[len(vertices) - 1][1] = ((ppos.origin - ppos.basis.orthonormalized() * Vector3(wid, 0, 0)))
				vertices[len(vertices) - 1][2] = ppos.origin
		
		current_trail_node.global_transform.basis = ViVeEnvironment.get_singleton().scene.global_transform.basis
		#current_trail_node.global_transform.basis = get_tree().get_current_scene().global_transform.basis
		current_trail.clear_surfaces()
		
		if vertices.size() > 0 : # check if we actually got stuff to make
			current_trail.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
			for i:Basis in vertices:
				if true:
				#if len(i) > 0:
					# with the vulkan renderer (forward+ and mobile) you will get the following error
					## "draw_list_draw: Too few vertices (2) for the render primitive set in the render pipeline (3)."
					
					current_trail.surface_add_vertex(i[0] - global_transform.origin)
					current_trail.surface_add_vertex(i[1] - global_transform.origin)
			
			current_trail.surface_end()





