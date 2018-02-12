<?php
$onoffpy = $_GET[ 'onoffpy' ];

if ( $onoffpy === 'gpiotimer.py' ) {
	exec( '/usr/bin/sudo /usr/bin/killall -9 /root/gpiotimer.py &> /dev/null' );
	exec( '/usr/bin/sudo /root/gpiotimer.py &> /dev/null &' );
	die();
}

echo exec( '/usr/bin/sudo /root/'.$onoffpy );
