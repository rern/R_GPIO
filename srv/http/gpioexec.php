<?php
$onoffpy = $_GET[ 'onoffpy' ];

if ( $onoffpy === 'gpiotimer.py' ) {
	exec( '/usr/bin/killall -9 /root/gpiotimer.py &> /dev/null' );
	exec( '/root/gpiotimer.py &> /dev/null &' );
	die();
}

echo exec( '/usr/bin/sudo /root/'.$onoffpy );
