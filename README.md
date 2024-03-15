# VitaVehicle - "Realistic" Car Physics (g-rcp2/RCP4)

# ![image](https://github.com/jreo03/g-rcp2/assets/88580430/7bc9ad0f-bc1e-4500-8712-d5b1b93193d5) (Beta - Godot 4.2 Fix)

(gles3 renderer was used in screenshot)

# About

VitaVehicle is a raycast-based car simulator that simulates engine, transmission, and slip algorithm. This is the second iteration of g-rcp, and it's the fourth generation of my own vehicle dynamics since 2017, as well as the usage of the Blender game engine. This was also ported from BGE despite that it isn't even published for that software yet at this time.

# Help

Help can be found in the VitaVehicle Interface once you've opened the project file via Godot editor.

# Tip

* Unit Scale: 0.30592 (1 metre = 3.268828 in translation)
* This project isn't novice-friendly.

### Credits

* Eclipse SRC by shotman_16
* Godot 4 Conversion & Fix - [r0401](https://github.com/r0401)
* Further Godot 4 optimizations and code reorganizations: [c08oprkiua](https://github.com/c08oprkiua)

### Current Acknowledged Issues

* In-app documentation is not updated to the most recent changes (being worked on).
* Controls are buggy:
  * Touch/accelerometer controls need to be re-implemented.
  * On Android, analog trigger values (taken from a DualShock 4) rest at 50% instead of 0%. This issue is not present on Linux.
