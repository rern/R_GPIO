<?php
$command = $_GET[ 'command' ];

if ( $command === 'timer' ) {
	exec( '/usr/bin/sudo /usr/bin/killall -9 gpiotimer.py &> /dev/null' );
	exec( '/usr/bin/sudo /root/gpiotimer.py &> /dev/null &' );
	// broadcast to remove idle reset infobox
	exec( '/usr/bin/curl -s -v -X POST "http://localhost/pub?id=gpio" -d "{ \"state\": \"RESET\" }"' );
} else if ( $command === 'reboot' ) {
	exec( '/usr/bin/sudo /root/gpiooff.py' );
	$part = exec( '/usr/bin/sudo /usr/bin/mount | grep "on / " | cut -d" " -f1' );
	$bootpart = substr( $part, -1 ) - 1;
	// for older kernel
	$buildversion = exec( 'redis-cli get buildversion' );
	if ( $buildversion === 'beta-20160313' ) {
		exec( "/usr/bin/sudo /bin/echo $bootpart > /sys/module/bcm2709/parameters/reboot_part" );
	} else {
		exec( "/usr/bin/sudo /var/www/command/rune_shutdown; /usr/bin/reboot $bootpart" );
	}
} else if ( $command === 'poweroff' ) {
	exec( '/usr/bin/sudo /root/gpiooff.py; /var/www/command/rune_shutdown;' );
} else {
	echo exec( '/usr/bin/sudo /root/'.$command );
}
