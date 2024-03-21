@tool
extends Node

class_name ViVeSimulation
#This is VitaVehicleSimulation

var misc_smoke:bool = true

enum GearAssist {
	Manual = 0,
	Semi_manual = 1,
	Auto = 2,
}

var GearAssistant:int = 2 # 0 = manual, 1 = semi-manual, 2 = auto

@export var universal_controls:ViVeCarControls = ViVeCarControls.new()

func fastest_wheel(array:Array[ViVeWheel]) -> ViVeWheel:
	var val:float = -10000000000000000000000000000000000.0
	var obj:ViVeWheel
	
	for i:ViVeWheel in array:
		val = max(val, abs(i.absolute_wv))
		
		if val == abs(i.absolute_wv):
			obj = i
	
	return obj

func slowest_wheel(array:Array[ViVeWheel]) -> ViVeWheel:
	var val:float = 10000000000000000000000000000000000.0
	var obj:ViVeWheel
	
	for i:ViVeWheel in array:
		val = min(val, abs(i.absolute_wv))
		
		if val == abs(i.absolute_wv):
			obj = i
	
	return obj

func alignAxisToVector(xform:Transform3D, norm:Vector3) -> Transform3D: # i named this literally out of blender
	xform.basis.y = norm
	xform.basis.x = -xform.basis.z.cross(norm)
	xform.basis = xform.basis.orthonormalized()
	return xform

