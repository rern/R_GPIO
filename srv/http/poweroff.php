<?php
$status = exec('sudo /root/gpiostatus.py');
$status = json_decode($status, true);
if ($status['pullup'] == 0) {
	exec('/usr/bin/curl -s -v -X POST "http://localhost/pub?id=gpio" -d '.escapeshellarg('"OFF"'));
	$pullup = exec('/usr/bin/sudo /root/gpiooff.py');

	if ($pullup != 1) {
	  exec('/usr/bin/curl -s -v -X POST "http://localhost/pub?id=gpio" -d '.escapeshellarg('"FAILED"'));
	  die(); // for 'include' exit in bootrune.php
	}
}
exec('/var/www/command/rune_shutdown');
