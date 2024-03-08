extends Node3D
class_name ViVeTyreSmoke

@export var dirt_type:bool = false

@onready var velo1:Marker3D = get_node("../../../velocity")
@onready var velo2:Marker3D = get_node("../../../velocity2")
@onready var wheel_self:ViVeWheel = get_node("../../..")
@onready var revolve_l:Node3D = $revolvel
@onready var revolve_r:Node3D = $revolver

var tyre_width:float

func _ready() -> void:
	tyre_width = wheel_self.TyreSettings.Width_mm

func _physics_process(_delta:float) -> void:
	if VitaVehicleSimulation.misc_smoke:
		visible = true
		run_smoke()

func run_smoke() -> void:
	var velo1_v:Vector3 = wheel_self.velocity
	
	revolve_l.position.x = float(tyre_width) * 0.0030592 / 2
	revolve_r.position.x = - float(tyre_width) * 0.0030592 / 2
	
	$static.global_rotation = velo1.global_rotation
	var direction:Vector3 = velo1_v * 0.75
	
	var spin:float = wheel_self.slip_perc.y
	var j:float = abs(wheel_self.wv)
	
	j = minf(j, 10.0)
	
	spin = clampf(spin, -j, j)
	
	direction.z += spin
	
	for i:CPUParticles3D in $static.get_children():
		i.direction = direction
		i.initial_velocity_min = direction.length()
		i.initial_velocity_max = direction.length()
		i.position.y = -wheel_self.w_size
		i.emitting = false
	
	for revolve:Node3D in [revolve_l, revolve_r]:
		for i:CPUParticles3D in revolve.get_children():
			if wheel_self.wv > 0:
				i.orbit_velocity_max = 1.0
				i.orbit_velocity_min = 1.0
			else:
				i.orbit_velocity_max = -1.0
				i.orbit_velocity_min = -1.0
			i.emitting = false
	
	var should_emit:bool = (abs(wheel_self.wv * wheel_self.w_size) > velo1_v.length() + 10.0)
	
	if wheel_self.is_colliding():
		if dirt_type:
			if wheel_self.surface_vars.ground_dirt:
				if velo1_v.length() > 20.0:
					$static/lvl1.emitting = true
					if should_emit:
						$revolvel/lvl1.emitting = true
						$revolver/lvl1.emitting = true
				if wheel_self.slip_perc2 > 1.0:
					if wheel_self.slip_perc.length() > 80.0:
						$static/lvl3.emitting = true
						if should_emit:
							$revolvel/lvl3.emitting = true
							$revolver/lvl3.emitting = true
					elif wheel_self.slip_perc.length() > 40.0:
						$static/lvl2.emitting = true
						if should_emit:
							$revolvel/lvl2.emitting = true
							$revolver/lvl2.emitting = true
		else:
			if not wheel_self.surface_vars.ground_dirt:
				if wheel_self.slip_perc2 > 1.0:
					if wheel_self.slip_perc.length() > 80.0:
						$static/lvl3.emitting = true
						if should_emit:
							$revolvel/lvl3.emitting = true
							$revolver/lvl3.emitting = true
					elif wheel_self.slip_perc.length() > 40.0:
						$static/lvl2.emitting = true
						if should_emit:
							$revolvel/lvl2.emitting = true
							$revolver/lvl2.emitting = true
					elif wheel_self.slip_perc.length() > 20.0:
						$static/lvl1.emitting = true
						if should_emit:
							$revolvel/lvl1.emitting = true
							$revolver/lvl1.emitting = true
