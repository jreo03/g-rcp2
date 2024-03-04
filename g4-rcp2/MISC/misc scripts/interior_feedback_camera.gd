extends Camera3D


var defaultpos
var defaultrot
var mometum = Vector3(0,0,0)
var pastspeed = Vector3(0,0,0)
var mometum_ro = Vector3(0,0,0)
var pastspeed_ro = Vector3(0,0,0)

func _ready():
	defaultpos = position
	defaultrot = rotation

func _physics_process(delta):
	pastspeed -= (pastspeed - get_parent().velocity)*0.1
	mometum = get_parent().velocity - pastspeed
	mometum_ro = get_parent().angular_velocity
	mometum.x /= 2.0
	mometum_ro.y /= 2.0
	position = defaultpos-(mometum/15.0)
	rotation = Vector3(defaultrot.x-(mometum_ro.x/15.0),defaultrot.y-(mometum_ro.y/15.0) -get_parent().steer*0.25,defaultrot.z-(mometum_ro.z/15.0))
