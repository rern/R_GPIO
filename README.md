+R GPIO
---
Control GPIO-connected relay module for power on / off equipments.
- Power `on` `off` audio equipments in sequence**
- Up to 4 equipments(relays)
- Delay setting for each equipment(relay)
- Idle timer power off
	- Notify last minute warning with countdown
	- Reset on play or `reset` button during warning

<hr>

![warning](https://github.com/rern/_assets/blob/master/R_GPIO/warning_el.png) **Warning**
- A relay module can be connected to GPIO, to see how it works, by anyone with basic skill.  
- Wrong connection may just damage your RPi. (only 5V)  
- Requires **electrical skill and knowledge** to connect these relays as power switches. (110V / 220V)  
- **Electric shock can kill.**  

<hr>

### Relay module
Dirt cheap on ebay

![relay](https://github.com/rern/_assets/raw/master/R_GPIO/relay.jpg)  
![relay](https://github.com/rern/_assets/raw/master/R_GPIO/relay_module_circuit.png)

- [Relay module](https://www.ebay.com/sch/i.html?_from=R40&_nkw=5V+4+Channel+Relay+Module+High%2FLow&_sacat=0&_sop=15)
    - use **high/low level trigger** and set to **high**
	- For complete isolation:
		- Remove all jumpers
		- Connect all center pins to RPi ground
		- Power relay module with a separated 5V power supply

### The box
- LEDs for GPIO 3.3V status
- Switches
	- Normal : GPIO 3.3V > LED ON, relay ON
	- Off : GPIO 3.3V > LED ON, relay OFF
	- Bypass : Direct 5V > LED OFF, relay ON
	
[![11](https://github.com/rern/_assets/blob/master/RuneUI_GPIO/GPIOs/11.jpg)](https://github.com/rern/_assets/blob/master/RuneUI_GPIO/11.jpg?raw=1)
[![8](https://github.com/rern/_assets/blob/master/RuneUI_GPIO/GPIOs/08.jpg)](https://github.com/rern/_assets/blob/master/RuneUI_GPIO/08.jpg?raw=1)
[![9](https://github.com/rern/_assets/blob/master/RuneUI_GPIO/GPIOs/09.jpg)](https://github.com/rern/_assets/blob/master/RuneUI_GPIO/09.jpg?raw=1)
[![10](https://github.com/rern/_assets/blob/master/RuneUI_GPIO/GPIOs/10.jpg)](https://github.com/rern/_assets/blob/master/RuneUI_GPIO/10.jpg?raw=1)
