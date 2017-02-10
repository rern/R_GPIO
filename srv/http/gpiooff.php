<?php
exec('/usr/bin/sudo /root/gpiooff.py', $pullup);
// response to only initiator (no broadcast)
echo $pullup;
