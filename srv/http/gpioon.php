<?php
$pullup = exec( '/usr/bin/sudo /root/gpioon.py' );
// response to only initiator (no broadcast)
echo $pullup;
