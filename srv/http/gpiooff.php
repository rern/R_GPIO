<?php
// check status
$status = exec('/usr/bin/sudo /root/gpiostatus.py');
$json = json_decode($status, true);
$pullup = $json['pullup'];
//echo $pullup;
// response to only initiator (no broadcast)

if ($pullup == 1) die('Already OFF'); // R pullup high > no signal

// broadcast message (pushstream)
exec('/usr/bin/curl -s -v -X POST "http://localhost/pub?id=gpio" -d '.escapeshellarg('"OFF"'));
// send command
if (!isset($_GET['devnull'])) {
	$pullup = exec('/usr/bin/sudo /root/gpiooff.py');
} else {
	exec('/usr/bin/sudo /root/gpiooff.py > /dev/null 2>&1 &'); // gpio disabled > run in backdground 
}

// if pullup failed, broadcast message
if ($pullup != 1) exec('/usr/bin/curl -s -v -X POST "http://localhost/pub?id=gpio" -d '.escapeshellarg('"FAILED"'));
