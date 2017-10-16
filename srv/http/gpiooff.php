<?php
$pullup = exec( '/usr/bin/sudo /root/gpiooff.py' );
// response to only initiator (no broadcast)
echo $pullup;
