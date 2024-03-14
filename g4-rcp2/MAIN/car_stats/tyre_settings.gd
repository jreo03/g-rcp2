extends Resource
##A [Resource] for tyre settings.
class_name ViVeTyreSettings

##Grip and traction amplification.
var GripInfluence:float = 1.0
##Width of the tyre, in nanometers.
var Width_mm:int = 185
##Aspect ratios are delivered in percentages. 
##Tire makers calculate the aspect ratio by dividing a tire's height off the rim by its width. 
##If a tire has an aspect ratio of 70, it means the tire's height is 70's of its width.
var Aspect_Ratio:int = 60
##Rim size, in inches(?).
var Rim_Size_in:int = 14
