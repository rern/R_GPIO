How It Works
---
```sh
set gpio initial state to off on boot with 'systemd'
set '/etc/sudoers.d/sudoers' to allow root command
show running gpiotimer.py [and sleep] process >> # top -b | grep -e gpiotimer.py [-e sleep] (-e = each name)
	or # top > 'L' - Locate string > gpiotimer.py

run root command (with python script file)
	jquery '$.get();' >> php 'exec();' >> python 'os.system()'
		php 'exec' needs full path command (plus 'sudo' for root command)
		python 'os.sytem' no need ('subprocess' is too complicated for piping)
	
broadcast message:
	use nginx 'pushstream' websocket
	php: exec('/usr/bin/curl -s -v -X POST "http://localhost/pub?id=amp" -d '.escapeshellarg('"message"'));
	python: requests.post("http://localhost/pub?id=amp", json="message")
	
ON / OFF:
	<jquery >
	'get' php >> $.get('gpioon.php' / 'gpiooff.php');
		<php>
		'exec' python >> exec('sudo /root/gpiostatus.py');
			<python>
			'gpio' get pin status
			'print' status back to php
		* if already on / off, 'die' - not broadcast
	notify caller only
	
		'curl' broadcast 'ON' / 'OFF' >> exec('/usr/bin/curl -s -v -X POST "http://localhost/pub?id=amp" -d \"ON\"');
	notify all
	
		'exec' python >> exec('sudo /root/gpioon.py' / 'gpiooff.py');
				(off only) 'os.system' kill idle timer process >> os.system('killall -9 gpiotimer.py')
				'gpio' pulldown / pullup and response status
		* if failed, 'curl' broadcast 'FAILED'
	notify all to replace current broadcast 'ON' / 'OFF'
	
		(on only) 'exec' python - start idle timer 'in background' >> exec('sudo /root/gpiotimer.py > /dev/null 2>&1 &');
			'while' loop
			'python-mpd2' get mpd 'state'
			* if 'play', reset loop count
			* if not 'play', decrement loop count
			'requests.post' broadcast warning on last loop
	notify all
	* if 'reset', 'get' php >> $.get('gpioon.php' / 'gpiotimmerreset.php');
		'exec' kill idle timer process >> exec('sudo /usr/bin/killall -9 gpiotimer.py');
		'exec' python - restart idle timer 'in background' >> exec('sudo /root/gpiotimmer.py' > /dev/null 2>&1 &');
		
			'os.system' php gpiooff.php
```
