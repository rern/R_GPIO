<?php
$pullup = exec( '/usr/bin/sudo /root/'.$_GET[ 'gpio' ] );
// response to only initiator (no broadcast)
echo $pullup;
