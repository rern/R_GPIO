How It Works
---

- set gpio initial state to off on boot with `systemd`
- set `/etc/sudoers.d/http` to allow root command without password
- run `sudo` commands
	- **jquery** `$.get(...);` >> **php** `exec(...);` >> **python** `os.system(...)`
	- php `exec()` and python `os.system` need full path command (plus `sudo` for root command)
- broadcast messagewith NGINX 'pushstream' websocket
	- **php**  `exec('/usr/bin/curl -s -v -X POST "http://localhost/pub?id=amp" -d '.escapeshellarg('"message"'));`
	- **python** `requests.post("http://localhost/pub?id=amp", json="message")`
<hr>

- **jquery** cannot run python directly
	- run php
		- `$.get('gpioon.php' / 'gpiooff.php');`

- **php** for js <-> python
	- get status
		- `exec('sudo /root/gpiostatus.py');`
	- broadcast
		- `exec('/usr/bin/curl -s -v -X POST "http://localhost/pub?id=amp" -d \"ON\"');`
	- run python on / off
		- `exec('sudo /root/gpioon.py' / 'gpiooff.py');`
	- start python timer in background
		- `exec('sudo /root/gpiotimer.py > /dev/null 2>&1 &');`
		
- **python** gpio control
	- on / off
		- `RPi.GPIO`
	- broadcast
		- `python-requests`
	- idle timer 
	- poll idle state
		- `python-mpd2`
		- `cat /proc/asound/card*/pcm*/sub*/status`
	- broadcast last minute warning
	- off - kill idle timer process
		- `os.system('killall -9 gpiotimer.py')`
