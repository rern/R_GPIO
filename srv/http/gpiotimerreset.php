<?php
exec('/usr/bin/sudo /usr/bin/pgrep gpiotimer.py', $pid);
if ($pid) exec('/usr/bin/sudo /usr/bin/killall -9 gpiotimer.py; /root/gpiotimer.py > /dev/null 2>&1 &');
?>
