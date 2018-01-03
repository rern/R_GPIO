<?php
exec( '/usr/bin/sudo /usr/bin/killall -9 gpiotimer.py &> /dev/null' );
exec( '/usr/bin/sudo /root/gpiotimer.py &> /dev/null &' );
