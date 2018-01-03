<?php
$pid = exec( '/usr/bin/sudo /usr/bin/pgrep gpiotimer.py' );
if ( $pid ) exec( '/usr/bin/sudo /usr/bin/killall -9 gpiotimer.py; /root/gpiotimer.py' );
