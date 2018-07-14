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
	$kernel = exec( '/usr/bin/sudo /usr/bin/uname -r | cut -d"-" -f1' );
	if ( $kernel >= '4.4.39' ) {
		exec( "/var/www/command/rune_shutdown; /usr/bin/reboot $bootpart" );
	} else {
		exec( "/bin/echo $bootpart > /sys/module/bcm2709/parameters/reboot_part" );
		exec( "/var/www/command/rune_shutdown; /usr/bin/reboot" );
	}
} else if ( $command === 'poweroff' ) {
	exec( "/var/www/command/rune_shutdown;" );
} else {
	echo exec( '/usr/bin/sudo /root/'.$command );
}
