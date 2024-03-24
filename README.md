# VitaVehicle - "Realistic" Car Physics (g-rcp2/RCP4)

# ![image](https://github.com/jreo03/g-rcp2/assets/88580430/7bc9ad0f-bc1e-4500-8712-d5b1b93193d5) (Beta - Godot 4.2.1 Version)

(GLES3 renderer was used in screenshot)

# About

VitaVehicle is a raycast-based car simulator that simulates engine, transmission, and slip algorithm. This is the second iteration of g-rcp, and it's the fourth generation of my own vehicle dynamics since 2017, as well as the usage of the Blender game engine. This was also ported from BGE despite that it isn't even published for that software yet at this time.

# Help

Class references can be looked up in the editor like any native class of the engine;

* `ViVeCar` represents a vehicle in VitaVehicle.

* `ViVeWheel` represents the wheel of a ViVeCar.

* `ViVeEnvironment` represents the environment in which a VitaVehicle simulation runs. 

* ...And more, in the in-engine docs! Anything added by VitaVehicle will follow the naming convention of starting with `ViVe`, so that you can tell Vita Vehicle classes apart from other classes.

# Tip

* Unit Scale: 0.30592 (1 metre = 3.268828 in translation)
* The torque graph can be used to view the torque readout of a car in-editor without loading up a simulation. It can also track stat edits in real time if `constant refresh` is enabled.
* For a quick overview of what all VitaVehicle adds to the engine, type "ViVe" into the search box when looking through documentation.

### Credits

* Eclipse SRC by shotman_16
* Godot 4 Conversion & Fix - [r0401](https://github.com/r0401)
* Further Godot 4.2.1 optimizations & code reorganizations: [c08oprkiua](https://github.com/c08oprkiua)

### Current Acknowledged Issues

* In-editor plugin is unstable.
  * Torque graph does not update properly.
  * Collision editor has not been re-implemented. 
* Controller controls are buggy:
  * Incorrect axis mappings depending on the controller in use.
  * Axis deadzones not being accurate on Android.
* Bug: ground does not make special terrain SFX.
* Aqua Highway and the Synic EKI Rally have shader issues from being incompletely brought over from Godot 3. 
