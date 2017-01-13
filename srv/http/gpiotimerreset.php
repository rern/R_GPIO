<?php
exec('sudo /usr/bin/killall -9 gpiotimer.py');
exec('sudo /root/gpiotimer.py > /dev/null 2>&1 &');
