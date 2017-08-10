#RuneUI GPIO

_(For RuneAudio beta-20160313. Tested on RPi 3)_

GPIO connected relay module control  

Try it - [**Demo**](https://rern.github.io/RuneUI_GPIO/)  
Can be installed without relay module to play with interface.  

>[Features](#features)  
>[Things to get](#things-to-get)  
>[Things to do](#things-to-do)  
>[Before install](#before-install)  
>[Install](#install)  
>[Uninstall](#uninstall)  

![settings](https://github.com/rern/RuneUI_GPIO/blob/master/_repo/gpio.gif)  

Features
---

**Power `on` `off` audio equipments in sequence**
- up to 4 equipments(relays)
- delay setting for each equipment(relay)
- Notification broadcast for `on` `off`

**Idle timer power off**
- polling 'play' status every minute
- idle time setting
- notification last minute warning with countdown
- reset on play or `reset` button during warning

**Integrated into existing RuneUI**
- auto enable custom configured MPD on power on
- `GPIO` (speaker icon) button on the left of top bar
- change button icon and color on `on` `off`
- show button only when enable
- setting in `Menu` > `GPIO` (local browser: right click > `Fullscreen` (exit) > click `GPIO` tab)
- instantly update all fields on changing pins or names
- `RPi pin numbering` diagram included, show / hide on click
- Auto power off on reboot / shutdown
- Can be used with [**USB PC Remote**](https://github.com/rern/Rune_USB_PC_Remote)

**Easy install and (almost) hassel-free**
- Offline packages install
- Prompt for custom MPD configuration  

<hr>

![warning](https://github.com/rern/RuneUI_GPIO/blob/master/_repo/warning_el.png) **Warning**
- A relay module can be connected to GPIO, to see how it works, by anyone with basic skill.  
- Wrong connection may just damage your RPi. (only 5V)  
- Requires **electrical skill and knowledge** to connect these relays as power switches. (110V / 220V)  
- **Electric shock can kill.**  

<hr>

Things to get
---
Dirt cheap on ebay

![relay](https://github.com/rern/RuneUI_GPIO/blob/master/_repo/relay.jpg)
![jumper](https://github.com/rern/RuneUI_GPIO/blob/master/_repo/jumper.jpg)

- [Relay module](http://www.ebay.com/sch/i.html?_sacat=0&_nkw=4+channel+relay+module&_frs=1)
- [GPIO jumper wires](http://www.ebay.com/sch/i.html?_from=R40&_trksid=p2047675.m570.l1313.TR0.TRC0.H0.X10pcs+2pin+jumper.TRS0&_nkw=10pcs+2pin+jumper&_sacat=0)
- Power cables
- DIY enclosure

Things to do
---
(click for larger image)  
[![1](https://github.com/rern/RuneUI_GPIO/blob/master/_repo/GPIOs/1.jpg)](https://github.com/rern/RuneUI_GPIO/blob/master/_repo/1.jpg?raw=1)
[![2](https://github.com/rern/RuneUI_GPIO/blob/master/_repo/GPIOs/2.jpg)](https://github.com/rern/RuneUI_GPIO/blob/master/_repo/2.jpg?raw=1)
[![3](https://github.com/rern/RuneUI_GPIO/blob/master/_repo/GPIOs/3.jpg)](https://github.com/rern/RuneUI_GPIO/blob/master/_repo/3.jpg?raw=1)
[![4](https://github.com/rern/RuneUI_GPIO/blob/master/_repo/GPIOs/4.jpg)](https://github.com/rern/RuneUI_GPIO/blob/master/_repo/4.jpg?raw=1)
[![5](https://github.com/rern/RuneUI_GPIO/blob/master/_repo/GPIOs/5.jpg)](https://github.com/rern/RuneUI_GPIO/blob/master/_repo/5.jpg?raw=1)
[![6](https://github.com/rern/RuneUI_GPIO/blob/master/_repo/GPIOs/6.jpg)](https://github.com/rern/RuneUI_GPIO/blob/master/_repo/6.jpg?raw=1)
[![7](https://github.com/rern/RuneUI_GPIO/blob/master/_repo/GPIOs/7.jpg)](https://github.com/rern/RuneUI_GPIO/blob/master/_repo/7.jpg?raw=1)

Before install
---
- RuneAudio has trouble with system wide upgrade. Do not `pacman -Syu` upgrage. 
- No need to connect relay module before install
- Power on DAC if external powered
- `Menu` > `MPD` complete all settings
- Make sure it works properly
- GPIO will enforce this setting every power on

_(MPD configuration can still be reset to default and setup manually.)_

Install
---
RuneAudio has trouble with system wide upgrade. Do not `pacman -Syu` upgrage.
```
wget -qN --show-progress https://raw.githubusercontent.com/rern/RuneUI_GPIO/master/install.sh; chmod +x install.sh; ./install.sh
```

Uninstall
---
```
./uninstall_gpio.sh
```
_Uninstalling will restore files to originals and delete all added ones._  
