How It Works
---

- set gpio initial state to off on boot with `systemd`
- set `/etc/sudoers.d/http` to allow root command without password
- run `sudo` commands
	- **jquery** `$.get(...);` >> **php** `exec(...);` >> **python** `os.system(...)`
	- php `exec()` and python `os.system` need full path command (plus `sudo` for root command)
- broadcast message with **NGINX pushstream** websocket
	- **python** `requests.post('http://localhost/pub?id=gpio', data='message')` ( or `json={'key':'value'}` )
	- **php**  `exec('/usr/bin/curl -s -v -X POST "http://localhost/pub?id=gpio" -d '.escapeshellarg('"message"'));`
	- **bash** `curl -s -v -X POST 'http://localhost/pub?id=gpio' -d 'message'`
<hr>

- **jquery** cannot run python directly
	- run php
		- `$.get('gpioon.php' / 'gpiooff.php');`

- **php** for js <-> python
	- get status
		- `exec('sudo /root/gpiostatus.py');`
	- run python on / off
		- `exec('sudo /root/gpioon.py' / 'gpiooff.py');`

**`gpioon.py`**
- broadcast
	- `requests.post('http://localhost/pub?id=gpio', json='ON')` ( retrive by `data[0]` )
- gpio pulldown

**`gpiotimer.py`**
- poll idle state
	- `python-mpd2`
	- `cat /proc/asound/card*/pcm*/sub*/status`
- broadcast last minute warning
	- `requests.post('http://localhost/pub?id=gpio', json=str(60) +'IDLE')`
	
**`gpiooff.py`**
- broadcast
	- `requests.post('http://localhost/pub?id=gpio', json='OFF')`
- kill idle timer process
	- `os.system('killall -9 gpiotimer.py')`
- gpio pullup
