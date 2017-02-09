<?php
// check status
$status = exec('/usr/bin/sudo /root/gpiostatus.py');
$json = json_decode($status, true);
$pullup = $json['pullup'];
//echo $pullup;
// response to only initiator (no broadcast)
if ($pullup == 0) die('Already ON'); // R pulldown low > trigger signal

// broadcast message (pushstream)
exec('/usr/bin/curl -s -v -X POST "http://localhost/pub?id=gpio" -d \"ON\"'); // message non-char in curl must be escaped

// send command
$pullup = exec('/usr/bin/sudo /root/gpioon.py');

if ($pullup == 0) {
  // send gpio timer command (run in background)
  exec('/usr/bin/sudo /root/gpiotimer.py > /dev/null 2>&1 &');
  // restart midori for show/hide volume
  exec('/usr/bin/sudo /usr/bin/killall midori; sleep 1; startx > /dev/null 2>&1 &');
} else {
  // if pulldown failed, broadcast message
  exec('/usr/bin/curl -s -v -X POST "http://localhost/pub?id=gpio" -d '.escapeshellarg('"FAILED"'));
}
