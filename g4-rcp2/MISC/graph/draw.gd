extends Control

@export_enum("ft⋅lb", "nm", "kg/m") var Torque_Unit:int = 1
@export_enum("hp", "bhp", "ps", "kW") var Power_Unit:int = 0


#engine
@export var RevSpeed:float = 2.0 # Flywheel lightness
@export var EngineFriction:float = 18000.0
@export var EngineDrag:float = 0.006
@export var ThrottleResponse:float = 0.5

#ECU
@export var IdleRPM:float = 800.0 # set this beyond the rev range to disable it, set it to 0 to use this vvt state permanently
@export var RPMLimit:float = 7000.0 # set this beyond the rev range to disable it, set it to 0 to use this vvt state permanently
@export var VVTRPM:float = 4500.0 # set this beyond the rev range to disable it, set it to 0 to use this vvt state permanently

#torque normal state
@export var TorqueNormal:ViVeCarTorque = ViVeCarTorque.new()

@export var TorqueVVT:ViVeCarTorque = ViVeCarTorque.new("VVT")
#torque @export variable valve timing triggered

@export var TurboEnabled:bool = false
@export var MaxPSI:float = 8.0
@export var TurboAmount:float = 1 # Turbo power multiplication.
@export var EngineCompressionRatio:float = 8.0 # Piston travel distance
@export var SuperchargerEnabled:bool = false # Enables supercharger
@export var SCRPMInfluence:float = 1.0
@export var BlowRate:float = 35.0
@export var SCThreshold:float = 6.0

@export var draw_scale:float = 0.005
@export var Generation_Range:float = 7000.0
@export var Draw_RPM:float = 800.0

var peakhp:Array[float] = [0.0,0.0]
var peaktq:Array[float] = [0.0,0.0]

func _ready() -> void:
	peakhp = [0.0,0.0]
	peaktq = [0.0,0.0]
	$torque.clear_points()
	$power.clear_points()
	var skip:int = 0
	for i in range(Generation_Range):
		if i > Draw_RPM:
			var car:ViVeCar = ViVeCar.new()
			#we do a little loop magic to make my job easier
			const carstats:PackedStringArray = [
			"EngineFriction","EngineDrag","RPM",
			"FloatRate","PSI","TurboAmount",
			"EngineCompressionRatio","TEnabled","VVTRPM"
			,"SCEnabled","SCRPMInfluence","BlowRate",
			"SCThreshold",
			]
			for stat in carstats:
				if (car.get(stat) != null) and (self.get(stat) != null):
					car.set(stat, self.get(stat))
			if car.get("torque_norm") != null:
				car.set("torque_norm", TorqueNormal)
			if car.get("torque_vvt") != null:
				car.set("torque_vvt", TorqueVVT)
			
			var tr:float = VitaVehicleSimulation.multivariate(car)
			var hp:float = (i / 5252.0) * tr
			
			if Torque_Unit == 1:
				tr *= 1.3558179483
			elif Torque_Unit == 2:
				tr *= 0.138255
			
			match Power_Unit:
				1:
					hp *= 0.986
				2:
					hp *= 1.01387
				3:
					hp *= 0.7457
			
			var tr_p:Vector2 = Vector2((i / Generation_Range) * size.x, size.y - (tr * size.y) * draw_scale)
			var hp_p:Vector2 = Vector2((i / Generation_Range) * size.x, size.y - (hp * size.y) * draw_scale)
			
			if hp > peakhp[0]:
				peakhp = [hp,i]
				$power/peak.position = hp_p
			
			if tr > peaktq[0]:
				peaktq = [tr,i]
				$torque/peak.position = tr_p
			
			skip -= 1
			if skip <= 0:
				$torque.add_point(tr_p)
				$power.add_point(hp_p)
				skip = 100
