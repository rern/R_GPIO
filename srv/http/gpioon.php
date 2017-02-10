<?php
exec('/usr/bin/sudo /root/gpioon.py', $pullup);
// response to only initiator (no broadcast)
echo $pullup;
