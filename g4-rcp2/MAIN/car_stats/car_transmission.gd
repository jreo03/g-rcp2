extends Resource
class_name ViVeCarTransmission

var su:bool = false
var sd:bool = false
var clutch:bool

var gear:int = 0
var clutchpedal:float = 0.0
var clutchin:bool = false
var clutchpedalreal:float = 0.0
var clock_mult:float = 1.0
var ratio:float = 0.0

@export var UseMouseSteering :bool = false

@export_enum("Fully Manual", "Automatic", "Continuously Variable", "Semi-Auto") var TransmissionType:int = 0
enum TransmissionIs {
	FULLY_MANUAL,
	AUTOMATIC,
	CONTINUOUSLY_VARIABLE,
	SEMI_AUTO
}

@export var GearAssist:GearAssistant = GearAssistant.new()

@export var OnClutchRate:float = 0.2
@export var OffClutchRate:float = 0.2
@export var MaxClutch:int = 1 #changed from float to int

@export_group("Ratios")
@export var GearRatios :Array[float] = [ 3.250, 1.894, 1.259, 0.937, 0.771 ]
@export var RatioMult:float = 9.5
@export var ReverseRatio:float = 3.153

@export var FinalDriveRatio:float = 4.250

func shift_up() -> void:
	if GearAssist.assist_level == 0:
		su = false
		if gear < len(GearRatios):
			if gearstress < GearGap:
				actualgear += 1
	elif GearAssist.assist_level == 2:
		su = false
		if gear < len(GearRatios):
			if rpm < GearAssist.clutch_out_RPM:
				actualgear += 1
			else:
				if actualgear < 1:
					actualgear += 1
					if rpm > GearAssistant[5]:
						clutchin = false
				else:
					if sassistdel > 0:
						actualgear += 1
					sassistdel = GearAssist.shift_delay / 2.0
					sassiststep = -4
					
					clutchin = true
					gasrestricted = true



func shift_down() -> void:
	pass

func manual_transmission():
	if clutch and not clutchin:
		clutchpedalreal -= OffClutchRate/clock_mult
	else:
		clutchpedalreal += OnClutchRate/clock_mult
		
	clutchpedalreal = clampi(clutchpedalreal, 0, MaxClutch)
	
	clutchpedal = 1.0 - clutchpedalreal
	
	if gear > 0:
		ratio = GearRatios[gear - 1] * FinalDriveRatio * RatioMult
	elif gear == -1:
		ratio = ReverseRatio*FinalDriveRatio*RatioMult
	
	if GearAssist.assist_level == 0:
		if su:
			su = false
			if gear < len(GearRatios):
				if gearstress < GearGap:
					actualgear += 1
		if sd:
			sd = false
			if gear > -1:
				if gearstress < GearGap:
					actualgear -= 1
	elif GearAssistant[1] == 1:
		if rpm < GearAssistant[5]:
			var irga_ca = (GearAssistant[5] - rpm) / (GearAssistant[5] - IdleRPM)
			clutchpedalreal = irga_ca * irga_ca
			if clutchpedalreal > 1.0:
				clutchpedalreal = 1.0
		else:
			if not gasrestricted and not revmatch:
				clutchin = false
		if su:
			su = false
			if gear < len(GearRatios):
				if rpm < GearAssistant[5]:
					actualgear += 1
				else:
					if actualgear < 1:
						actualgear += 1
						if rpm > GearAssistant[5]:
							clutchin = false
					else:
						if sassistdel > 0:
							actualgear += 1
						sassistdel = GearAssistant[0] / 2.0
						sassiststep = -4
						
						clutchin = true
						gasrestricted = true
		elif sd:
			sd = false
			if gear > -1:
				if rpm < GearAssistant[5]:
					actualgear -= 1
				else:
					if actualgear == 0 or actualgear == 1:
						actualgear -= 1
						clutchin = false
					else:
						if sassistdel > 0:
							actualgear -= 1
						sassistdel = GearAssistant[0]/2.0
						sassiststep = -2
						
						clutchin = true
						revmatch = true
						gasrestricted = false
	elif GearAssistant[1] == 2:
		var assistshiftspeed = (GearAssistant[4]/ratio)*GearAssistant[2]
		var assistdownshiftspeed = (GearAssistant[3] / abs((GearRatios[gear - 2] * FinalDriveRatio) * RatioMult)) * GearAssistant[2]
		if gear == 0:
			if gas:
				sassistdel -= 1
				if sassistdel < 0:
					actualgear = 1
			elif brake:
				sassistdel -= 1
				if sassistdel < 0:
					actualgear = -1
			else:
				sassistdel = 60
		elif linear_velocity.length()<5:
			if not gas and gear == 1 or not brake and gear == -1:
				sassistdel = 60
				actualgear = 0
		if sassiststep == 0:
			if rpm < GearAssistant[5]:
				var irga_ca = (GearAssistant[5] - rpm) / (GearAssistant[5] - IdleRPM)
				clutchpedalreal = irga_ca*irga_ca
				if clutchpedalreal > 1.0:
					clutchpedalreal = 1.0
			else:
				clutchin = false
			if not gear == -1:
				if gear < len(GearRatios) and linear_velocity.length() > assistshiftspeed:
					sassistdel = GearAssistant[0]/2.0
					sassiststep = -4
					
					clutchin = true
					gasrestricted = true
				if gear > 1 and linear_velocity.length() < assistdownshiftspeed:
					sassistdel = GearAssistant[0] / 2.0
					sassiststep = -2
					
					clutchin = true
					gasrestricted = false
					revmatch = true
	#s assist step
	if sassiststep == -4 and sassistdel < 0:
		sassistdel = GearAssistant[0] / 2
		if gear < len(GearRatios):
			actualgear += 1
		sassiststep = -3
	elif sassiststep == -3 and sassistdel < 0:
		if rpm > GearAssistant[5]:
			clutchin = false
		if sassistdel < -GearAssistant[6]:
			sassiststep = 0
			gasrestricted = false
	elif sassiststep == -2 and sassistdel < 0:
		sassiststep = 0
		if gear > -1:
			actualgear -= 1
		if rpm > GearAssistant[5]:
			clutchin = false
		gasrestricted = false
		revmatch = false
	gear = actualgear


func transmission():
	su = Input.is_action_just_pressed("shiftup") and not UseMouseSteering or Input.is_action_just_pressed("shiftup_mouse") and UseMouseSteering
	sd = Input.is_action_just_pressed("shiftdown") and not UseMouseSteering or Input.is_action_just_pressed("shiftdown_mouse") and UseMouseSteering
	
	var clutch:bool = Input.is_action_pressed("clutch") and not UseMouseSteering or Input.is_action_pressed("clutch_mouse") and UseMouseSteering
	if not GearAssist.assist_level == 0:
		clutch = Input.is_action_pressed("handbrake") and not UseMouseSteering or Input.is_action_pressed("handbrake_mouse") and UseMouseSteering
	clutch = not clutch
	
	if TransmissionType == TransmissionIs.FULLY_MANUAL:
		if clutch and not clutchin:
			clutchpedalreal -= OffClutchRate / clock_mult
		else:
			clutchpedalreal += OnClutchRate / clock_mult
		
		clutchpedalreal = clampi(clutchpedalreal, 0, MaxClutch)
		
		clutchpedal = 1.0 - clutchpedalreal
		
		if gear > 0:
			ratio = GearRatios[gear - 1] * FinalDriveRatio * RatioMult
		elif gear == -1:
			ratio = ReverseRatio * FinalDriveRatio * RatioMult
		
		if GearAssist.assist_level == 0:
			if su:
				su = false
				if gear < len(GearRatios):
					if gearstress < GearGap:
						actualgear += 1
			if sd:
				sd = false
				if gear > -1:
					if gearstress < GearGap:
						actualgear -= 1
		elif GearAssistant[1] == 1:
			if rpm < GearAssistant[5]:
				var irga_ca = (GearAssistant[5] - rpm) / (GearAssistant[5] - IdleRPM)
				clutchpedalreal = irga_ca * irga_ca
				if clutchpedalreal > 1.0:
					clutchpedalreal = 1.0
			else:
				if not gasrestricted and not revmatch:
					clutchin = false
			if su:
				su = false
				if gear < len(GearRatios):
					if rpm < GearAssistant[5]:
						actualgear += 1
					else:
						if actualgear < 1:
							actualgear += 1
							if rpm > GearAssistant[5]:
								clutchin = false
						else:
							if sassistdel > 0:
								actualgear += 1
							sassistdel = GearAssistant[0] / 2.0
							sassiststep = -4
							
							clutchin = true
							gasrestricted = true
			elif sd:
				sd = false
				if gear > -1:
					if rpm < GearAssistant[5]:
						actualgear -= 1
					else:
						if actualgear == 0 or actualgear == 1:
							actualgear -= 1
							clutchin = false
						else:
							if sassistdel > 0:
								actualgear -= 1
							sassistdel = GearAssistant[0]/2.0
							sassiststep = -2
							
							clutchin = true
							revmatch = true
							gasrestricted = false
		elif GearAssistant[1] == 2:
			var assistshiftspeed = (GearAssistant[4]/ratio)*GearAssistant[2]
			var assistdownshiftspeed = (GearAssistant[3] / abs((GearRatios[gear - 2] * FinalDriveRatio) * RatioMult)) * GearAssistant[2]
			if gear == 0:
				if gas:
					sassistdel -= 1
					if sassistdel < 0:
						actualgear = 1
				elif brake:
					sassistdel -= 1
					if sassistdel < 0:
						actualgear = -1
				else:
					sassistdel = 60
			elif linear_velocity.length()<5:
				if not gas and gear == 1 or not brake and gear == -1:
					sassistdel = 60
					actualgear = 0
			if sassiststep == 0:
				if rpm < GearAssistant[5]:
					var irga_ca = (GearAssistant[5] - rpm) / (GearAssistant[5] - IdleRPM)
					clutchpedalreal = irga_ca*irga_ca
					if clutchpedalreal > 1.0:
						clutchpedalreal = 1.0
				else:
					clutchin = false
				if not gear == -1:
					if gear < len(GearRatios) and linear_velocity.length() > assistshiftspeed:
						sassistdel = GearAssistant[0]/2.0
						sassiststep = -4
						
						clutchin = true
						gasrestricted = true
					if gear > 1 and linear_velocity.length() < assistdownshiftspeed:
						sassistdel = GearAssistant[0] / 2.0
						sassiststep = -2
						
						clutchin = true
						gasrestricted = false
						revmatch = true
		
		if sassiststep == -4 and sassistdel < 0:
			sassistdel = GearAssistant[0] / 2
			if gear < len(GearRatios):
				actualgear += 1
			sassiststep = -3
		elif sassiststep == -3 and sassistdel < 0:
			if rpm > GearAssistant[5]:
				clutchin = false
			if sassistdel < -GearAssistant[6]:
				sassiststep = 0
				gasrestricted = false
		elif sassiststep == -2 and sassistdel < 0:
			sassiststep = 0
			if gear > -1:
				actualgear -= 1
			if rpm > GearAssistant[5]:
				clutchin = false
			gasrestricted = false
			revmatch = false
		gear = actualgear
	
	elif TransmissionType == 1:
	
		
		clutchpedal = (rpm- float(AutoSettings[3])*(gaspedal*float(AutoSettings[2]) +(1.0-float(AutoSettings[2]))) )/float(AutoSettings[4])
		
		
		if not GearAssistant[1] == 2:
			if su:
				su = false
				if gear < 1:
					actualgear += 1
			if sd:
				sd = false
				if gear > -1:
					actualgear -= 1
		else:
			if gear == 0:
				if gas:
					sassistdel -= 1
					if sassistdel < 0:
						actualgear = 1
				elif brake:
					sassistdel -= 1
					if sassistdel < 0:
						actualgear = -1
				else:
					sassistdel = 60
			elif linear_velocity.length()<5:
				if not gas and gear == 1 or not brake and gear == -1:
					sassistdel = 60
					actualgear = 0
				
		if actualgear == -1:
			ratio = ReverseRatio*FinalDriveRatio*RatioMult
		else:
			ratio = GearRatios[gear - 1] * FinalDriveRatio * RatioMult
		if actualgear > 0:
			var lastratio = GearRatios[gear - 2] * FinalDriveRatio * RatioMult
			su = false
			sd = false
			for i in c_pws:
				if (i.wv/GearAssistant[2])>(float(AutoSettings[0])*(gaspedal*float(AutoSettings[2]) +(1.0-float(AutoSettings[2]))))/ratio:
					su = true
				elif (i.wv/GearAssistant[2])<((float(AutoSettings[0])-float(AutoSettings[1]))*(gaspedal*float(AutoSettings[2]) +(1.0-float(AutoSettings[2])))) /lastratio:
					sd = true
					
			if su:
				gear += 1
			elif sd:
				gear -= 1
			if gear < 1:
				gear = 1
			elif gear > len(GearRatios):
				gear = len(GearRatios)
		else:
			gear = actualgear
	elif TransmissionType == 2:
		
		clutchpedal = (rpm- float(AutoSettings[3])*(gaspedal*float(AutoSettings[2]) +(1.0-float(AutoSettings[2]))) )/float(AutoSettings[4])
		
#            clutchpedal = 1
		
		if not GearAssistant[1] == 2:
			if su:
				su = false
				if gear < 1:
					actualgear += 1
			if sd:
				sd = false
				if gear > -1:
					actualgear -= 1
		else:
			if gear == 0:
				if gas:
					sassistdel -= 1
					if sassistdel < 0:
						actualgear = 1
				elif brake:
					sassistdel -= 1
					if sassistdel < 0:
						actualgear = -1
				else:
					sassistdel = 60
			elif linear_velocity.length()<5:
				if not gas and gear == 1 or not brake and gear == -1:
					sassistdel = 60
					actualgear = 0
				
		gear = actualgear
		var wv:float = 0.0
		
		for i in c_pws:
			wv += i.wv/len(c_pws)
			
		cvtaccel -= (cvtaccel - (gaspedal*CVTSettings[0] +(1.0-CVTSettings[0])))*CVTSettings[1]

		var a = CVTSettings[4] / ((abs(wv)/10.0)*cvtaccel + 1.0)
		
		if a < CVTSettings[5]:
			a = CVTSettings[5]
		
		ratio = (CVTSettings[2]*10000000.0)/(abs(wv)*(rpm*a) +1.0)
		
		if ratio > CVTSettings[3]:
			ratio = CVTSettings[3]
	
	elif TransmissionType == 3:
		clutchpedal = (rpm- float(AutoSettings[3])*(gaspedal*float(AutoSettings[2]) +(1.0-float(AutoSettings[2]))) )/float(AutoSettings[4])
	
		if gear > 0:
			ratio = GearRatios[gear - 1] * FinalDriveRatio * RatioMult
		elif gear == -1:
			ratio = ReverseRatio*FinalDriveRatio*RatioMult
		
		if GearAssistant[1] < 2:
			if su:
				su = false
				if gear < len(GearRatios):
					actualgear += 1
			if sd:
				sd = false
				if gear > -1:
					actualgear -= 1
		else:
			var assistshiftspeed = (GearAssistant[4] / ratio) * GearAssistant[2]
			var assistdownshiftspeed = (GearAssistant[3] / abs((GearRatios[gear - 2] * FinalDriveRatio) * RatioMult)) * GearAssistant[2]
			if gear == 0:
				if gas:
					sassistdel -= 1
					if sassistdel < 0:
						actualgear = 1
				elif brake:
					sassistdel -= 1
					if sassistdel < 0:
						actualgear = -1
				else:
					sassistdel = 60
			elif linear_velocity.length()<5:
				if not gas and gear == 1 or not brake and gear == -1:
					sassistdel = 60
					actualgear = 0
			if sassiststep == 0:
				if not gear == -1:
					if gear < len(GearRatios) and linear_velocity.length() > assistshiftspeed:
						actualgear += 1
					if gear > 1 and linear_velocity.length() < assistdownshiftspeed:
						actualgear -= 1
		
		gear = actualgear
	
	clutchpedal = clampf(clutchpedal, 0.0, 1.0)
