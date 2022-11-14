extends Position3D

var default_cam_pos
var can_drag = false
var just_resetted = false


export var mobile_controls = NodePath()
export var car = NodePath()
export var debugger = NodePath()

var drag_velocity = Vector2(0,0)
var last_pos = Vector2(0,0)
var x_drag_unlocked = false
var y_drag_unlocked = false

var resetdel = 0
var default_zoom

func _ready():
	default_cam_pos = $orbit/Camera.translation
	default_zoom = default_cam_pos.z

func _process(delta):
	if has_node(debugger):
		car = get_node(debugger).car
	if has_node(car):
		
		if get_node(car).has_node("CAMERA_CENTRE"):
			look_at(get_node(car).get_node("CAMERA_CENTRE").global_translation,Vector3(0,1,0))
			translation = get_node(car).get_node("CAMERA_CENTRE").global_translation
		else:
			look_at(get_node(car).translation,Vector3(0,1,0))
			translation = get_node(car).translation
		translate_object_local(Vector3(0,0,14.5))
		
		$orbit.global_translation = get_node(car).global_translation
		$orbit/Camera.translation = default_cam_pos -$orbit.translation
		
func _physics_process(delta):
	
	if Input.is_action_pressed("zoom_out"):
		default_cam_pos.z += 0.05
	elif Input.is_action_pressed("zoom_in"):
		default_cam_pos.z -= 0.05
	
	if Input.is_action_pressed("CAM_orbit_left"):
		$orbit.rotation_degrees.y += 1
	elif Input.is_action_pressed("CAM_orbit_right"):	
		$orbit.rotation_degrees.y -= 1
	
	if Input.is_action_pressed("CAM_orbit_reset"):
		$orbit.rotation_degrees.y = 0.0
		default_cam_pos.z = default_zoom
		
	resetdel -= 1
		
func _input(event):
	if not mobile_controls == "":
		if get_node(mobile_controls).visible:
			can_drag = true
			for i in get_node(mobile_controls).get_children():
				if i.is_pressed():
					can_drag = false
			if event is InputEventScreenTouch:
				if can_drag:
					last_pos = event.position
					if not event.is_pressed():
						if resetdel>0:
							$orbit.rotation_degrees.y = 0.0
							default_cam_pos.z = default_zoom
							just_resetted = true
						resetdel = 15
			else:
				just_resetted = false

			if event is InputEventScreenDrag:
				if can_drag and not just_resetted:
					drag_velocity.x = event.position.x - last_pos.x
					drag_velocity.y = event.position.y - last_pos.y
					last_pos = event.position
					
					if abs(drag_velocity.y)>5.0:
						y_drag_unlocked = true
					if abs(drag_velocity.x)>5.0:
						x_drag_unlocked = true
					
					if y_drag_unlocked:
						default_cam_pos.z += drag_velocity.y/200.0
					if x_drag_unlocked:
						$orbit.rotation_degrees.y -= drag_velocity.x/2.0
					resetdel = -1
			if event.is_action_released("gas_mouse"):
				x_drag_unlocked = false
				y_drag_unlocked = false
			
