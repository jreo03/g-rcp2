extends Control

@export_enum("ft⋅lb", "nm", "kg/m") var Torque_Unit:int = 1
@export_enum("hp", "bhp", "ps", "kW") var Power_Unit:int = 0

#ECU
@export var IdleRPM:float = 800.0 # set this beyond the rev range to disable it, set it to 0 to use this vvt state permanently
@export var RPMLimit:float = 7000.0 # set this beyond the rev range to disable it, set it to 0 to use this vvt state permanently
@export var VVTRPM:float = 4500.0 # set this beyond the rev range to disable it, set it to 0 to use this vvt state permanently

#torque normal state
@export var TorqueNormal:ViVeCarTorque = ViVeCarTorque.new()

@export var TorqueVVT:ViVeCarTorque = ViVeCarTorque.new("VVT")
#torque @export variable valve timing triggered

@export var draw_scale:float = 0.005
@export var Generation_Range:float = 7000.0
@export var Draw_RPM:float = 800.0

var peakhp:Array[float] = [0.0,0.0]
var peaktq:Array[float] = [0.0,0.0]

var car:ViVeCar = ViVeCar.new()

#This keeps getting re-called somewhere when it shouldn't be, when swapping cars
func _ready() -> void:
	ViVeEnvironment.singleton.connect("car_changed", draw_graph)

func draw_graph() -> void:
	car = ViVeEnvironment.singleton.car
	Generation_Range = float(int(car.RPMLimit / 1000.0) * 1000 + 1000) #???
	Draw_RPM = car.IdleRPM
	calculate()
	draw_scale = 1.0 / max(peaktq[0], peakhp[0])
	calculate()

func calculate() -> void:
	peakhp = [0.0,0.0]
	peaktq = [0.0,0.0]
	$torque.clear_points()
	$power.clear_points()
	var skip:int = 0
	for i in range(Generation_Range):
		if i > Draw_RPM:
			car._rpm = i
			var trq:float = VitaVehicleSimulation.multivariate(car)
			var hp:float = (i / 5252.0) * trq
			
			if Torque_Unit == 1:
				trq *= 1.3558179483
			elif Torque_Unit == 2:
				trq *= 0.138255
			
			match Power_Unit:
				1:
					hp *= 0.986
				2:
					hp *= 1.01387
				3:
					hp *= 0.7457
			
			var tr_p:Vector2 = Vector2((i / Generation_Range) * size.x, size.y - (trq * size.y) * draw_scale)
			var hp_p:Vector2 = Vector2((i / Generation_Range) * size.x, size.y - (hp * size.y) * draw_scale)
			
			if hp > peakhp[0]:
				peakhp = [hp, i]
				$power/peak.position = hp_p
			
			if trq > peaktq[0]:
				peaktq = [trq, i]
				$torque/peak.position = tr_p
			
			skip -= 1
			if skip <= 0:
				$torque.add_point(tr_p)
				$power.add_point(hp_p)
				skip = 100
