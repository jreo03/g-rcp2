extends Spatial


onready var velo1 = get_node("../../../velocity")
onready var velo2 = get_node("../../../velocity2")
onready var wheel_self = get_node("../../..")

export var dirt_type = false

func _physics_process(delta):
	var velo1_v = get_parent().get_parent().get_parent().velocity
	var velo2_v = get_parent().get_parent().get_parent().velocity2
	
	visible = VitaVehicleSimulation.misc_smoke
	
	$revolvel.translation.x = float(wheel_self.TyreSettings["Width (mm)"]) *0.0030592/2
	$revolver.translation.x = -float(wheel_self.TyreSettings["Width (mm)"]) *0.0030592/2
	
	$static.global_rotation = velo1.global_rotation
	var direction = velo1_v*0.75
	
	var spin = wheel_self.slip_perc.y
	var j = abs(wheel_self.wv)
	if j>10.0:
		j = 10.0
	if spin>j:
		spin = j
	elif spin<-j:
		spin = -j
		
	direction.z += spin

	for i in $static.get_children():
		i.direction = direction
		i.initial_velocity = direction.length()
		i.translation.y = -wheel_self.w_size
		i.emitting = false


	for i in $revolvel.get_children():
		if wheel_self.wv>0:
			i.orbit_velocity = 1.0
		else:
			i.orbit_velocity = -1.0
		i.emitting = false
	for i in $revolver.get_children():
		if wheel_self.wv>0:
			i.orbit_velocity = 1.0
		else:
			i.orbit_velocity = -1.0
		i.emitting = false

	if wheel_self.is_colliding():
		if dirt_type:
			if wheel_self.ground_dirt:
				if velo1_v.length()>20.0:
					$static/lvl1.emitting = true
					if abs(wheel_self.wv*wheel_self.w_size)>velo1_v.length()+10.0:
						$revolvel/lvl1.emitting = true
						$revolver/lvl1.emitting = true
				if wheel_self.slip_perc2>1.0:
					if wheel_self.slip_perc.length()>80.0:
						$static/lvl3.emitting = true
						if abs(wheel_self.wv*wheel_self.w_size)>velo1_v.length()+10.0:
							$revolvel/lvl3.emitting = true
							$revolver/lvl3.emitting = true
					elif wheel_self.slip_perc.length()>40.0:
						$static/lvl2.emitting = true
						if abs(wheel_self.wv*wheel_self.w_size)>velo1_v.length()+10.0:
							$revolvel/lvl2.emitting = true
							$revolver/lvl2.emitting = true
		else:
			if not wheel_self.ground_dirt:
				if wheel_self.slip_perc2>1.0:
					if wheel_self.slip_perc.length()>80.0:
						$static/lvl3.emitting = true
						if abs(wheel_self.wv*wheel_self.w_size)>velo1_v.length()+10.0:
							$revolvel/lvl3.emitting = true
							$revolver/lvl3.emitting = true
					elif wheel_self.slip_perc.length()>40.0:
						$static/lvl2.emitting = true
						if abs(wheel_self.wv*wheel_self.w_size)>velo1_v.length()+10.0:
							$revolvel/lvl2.emitting = true
							$revolver/lvl2.emitting = true
					elif wheel_self.slip_perc.length()>20.0:
						$static/lvl1.emitting = true
						if abs(wheel_self.wv*wheel_self.w_size)>velo1_v.length()+10.0:
							$revolvel/lvl1.emitting = true
							$revolver/lvl1.emitting = true
