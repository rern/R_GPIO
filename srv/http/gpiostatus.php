<?php
exec('sudo /root/gpiostatus.py', $status);
echo $status[0]; // exec output array[0] = json
