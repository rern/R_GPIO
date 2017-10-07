How It Works
---

- set gpio initial state to off on boot with `systemd`
- set `/etc/sudoers.d/http` to allow root command without password
- run `sudo` commands
	- **jquery** `$.get(...);` >> **php** `exec(...);` >> **python** `os.system(...)`
	- php `exec()` and python `os.system` need full path command (plus `sudo` for root command)
- broadcast messagewith NGINX 'pushstream' websocket
	- **php**  `exec('/usr/bin/curl -s -v -X POST "http://localhost/pub?id=gpio" -d '.escapeshellarg('"message"'));`
	- **python** `requests.post("http://localhost/pub?id=gpio", json="message")`
	- **bash** `curl -s -v -X POST "http://localhost/pub?id=gpio" -d \"message\"`
<hr>

- **jquery** cannot run python directly
	- run php
		- `$.get('gpioon.php' / 'gpiooff.php');`

- **php** for js <-> python
	- get status
		- `exec('sudo /root/gpiostatus.py');`
	- run python on / off
		- `exec('sudo /root/gpioon.py' / 'gpiooff.py');`

- **python** gpio control
	- on / off
		- `RPi.GPIO`
	- **on** broadcast
		- `requests.post("http://localhost/pub?id=gpio", json="ON")`
	- idle timer
		- `exec('sudo /root/gpiotimer.py > /dev/null 2>&1 &');`
	- poll idle state
		- `python-mpd2`
		- `cat /proc/asound/card*/pcm*/sub*/status`
	- broadcast last minute warning
		- `requests.post("http://localhost/pub?id=gpio", json=str(60) +"IDLE")`
	- **off** - kill idle timer process
		- `os.system('killall -9 gpiotimer.py')`
