# BD1 "Chimera" repo

![chimera photo](images/chimera1.jpg)

**Chimera is 2,2" freestyle cinewhoop type drone, for 3S/4S batteries, with fully 3D printed construction**

- vmax
: 90-100kmh on full power
- Ready-to-flight mass(with lamp, battery and wings)
: <210grams
- Carry weight
: Can fly with GoPro camera
- Thrust
: >950grams
- flight time
: 1,5 - 5min
- estimated cost
: 500-550 USD

Youtube Video **(with old nano VTX camera)**:

[![YT video](https://img.youtube.com/vi/oZOXZiCAGSI/0.jpg)](https://www.youtube.com/watch?v=oZOXZiCAGSI)


## 3D printing
![chimera render](images/renderLeft.png)

All on 0.4 brass nozzle, make sure you have at least 5 pieces- CF filaments will wear off quickly. Trim Z-offset after every CF print

I don't recommend using SS nozzle becouse it's too cold for my printer.

### tips/info
>please use proper materials. Drone components will be hot or very hot. Printing parts with PLA or similar will cause melt your construction during flight. **If my cheap Sidewinder X4 printer can handle this materials- yours printer also can.**

>It's not cheap project- don't do it because of lack of funds. Buying a ready frame will be cheaper than buying CF filaments

>one battery for one 2-3 minutes flight. Make sure you have more than 1

### parts
- **duct-light**
: PA6, 3 wall loops, no supports, 20% honeycomb infill, concentric top surface, bottom surface and solid infill, rotate 180deg in X axis(upside down)
- **frame**
: PC-CF, 3 wall loops, no supports, 100% grid infill, rotate 35deg in Z axis
- **body**
: PETG-CF, 3 wall loops, tree strong supports, 100% grid infill
>remove supports under side vent pockets, camera axis holes, right tail vent pocket, VTX ant cable hole
- **wings**
: PLA GLOW, 3 wall loops, 80%, no supports, rotate 90deg in Y axis, to make sure base is parallel to table
- **cable mounts**
: TPU A95, 100%, 3 wall loops, X90 deg, Y-45deg
- **roof/mount roof**
: TPU A95, 100%, 3 wall loops, Y90 deg, tree support
>set top support interface spacing 0.2mm to get nice look
- **GNSS mount**
: TPU A95, 3 wal loops, X90 deg
- **Grip nuts, sleeves**
: PETG, 100%
- **cable lock**
: PETG, 100%, X90 deg
- **duct**
: PETG-CF, 3 wall loops, 100% infill
>very robust duct. It make your drone heavier thatn 225grams, but can handle drops from 20 meters into grass

## BOM
![chimera render](images/renderBack.png)

### 3D printed
- 1 x duct-light
- 1 x body
- 1 x FDM frame
- 1 x left wing
- 1 x right wing
- 4 x cable mount
- 1 x roof or mount roof
- 1 x GNSS mount
- 1 x cable lock
- 4 x camera sleeves
- 4 x FC sleeves 2mm
- 4 x FC sleeves 3mm
- 4 x grip nuts

### electronic
- [x] **FC**
: BETAFPV F405 4S 20A Toothpick Brushless Flight Controller V5 BLHeli_S (ICM42688)
>you can use any other 20A+, compatible with 3/4S and 26mm pitch
- [x] **propellers**
: GEMFAN 2218 3-blade Propellers (1.5mm shaft)
- [x] **motors**
: BETAFPV Lava series 1104 | 7200KV Brushless Motors
- [x] **receiver**
: SpeedyBee Nano 2.4G ExpressLRS ELRS Receiver
>or any other ELRS receiver which can fit into modules mounts in body
- [x] **camera**
: Foxxeer Cat 3 Micro(19x19mm) or other analog camera
- [x] **VTX**
: Foxeer Reaper Nano V2 VTx 5.8G 72CH 350mW Tramp
- [x] **Video antenna**
: Walksnail Avatar HD Mini 1s Lite
- [x] **battery**
: LAVA 3/4S 550mAh 75C
- [x] **GNSS**
: Foxeer M10Q-120 compass
- [ ] **Controller**
: Radiomaster Pocket Crush White ELRS LBT, or any other with ELRS and edgeTX
- [ ] **Googles**
: BETAFPV VR03 or any other analog googles
- [x] **Cable**
: MicroUSB angled cable for FC config
- [x] **Charger**
: iMax B6 V2 with some 12V supplier
- [x] **some drone lamp**
: if you want make night flies
- [x] **2 x additional XT30 connectors set**
: to connect battery to charger and FC
- [x] **red and black 18AWG silicon wire cables**
: to make connection with FC



### mechanical

- [x] 1x 10x130mm battery velcro strap
- [x] 8x 20mm M2 screws with barrel head for stack mount, and wing mount
>make sure you have spares- these screws can bend after hard landing :joy:
- [x] 4x 10mm M2 screws with barrel head for body mount
- [x] 12x M2 H3 D3.6mm brass insert
>you can recover it from broken parts, but make sure you have spares
- [x] 4x M2 1,6mm nut to lock stack screws

![chimera render](images/renderBack.png)
![chimera render](images/renderUp.png)
![chimera render](images/renderPerspective.png)

# todo list
- [ ] make case
- [ ] make assembly file
- [ ] record night fly
- [ ] record full power flight
- [ ] make assembly manual


*BD1 stands for "Bart's Design 1"*
