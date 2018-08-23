<?php
$command = $_GET[ 'command' ];
$sudo = '/usr/bin/sudo /usr/bin/';
$sudoS = '/usr/bin/sudo ';
if ( $command === 'timer' ) {
	exec( $sudo.'killall -9 gpiotimer.py &> /dev/null' );
	exec( $sudoS.'/root/gpiotimer.py &> /dev/null &' );
	// broadcast to remove idle reset infobox
	exec( $sudo.'curl -s -v -X POST "http://localhost/pub?id=gpio" -d "{ \"state\": \"RESET\" }"' );
} else if ( $command === 'reboot' ) {
	exec( $sudoS.'/root/gpiooff.py' );
	$part = exec( $sudo.'mount | grep "on / " | cut -d" " -f1' );
	$bootpart = substr( $part, -1 ) - 1;
	exec( $sudo.'echo '.$bootpart.' > /sys/module/bcm2709/parameters/reboot_part' );
	exec( $sudoS.'/var/www/command/rune_shutdown; '.$sudo.'reboot '.$bootpart );
} else if ( $command === 'poweroff' ) {
	exec( $sudoS.'/root/gpiooff.py; '.$sudoS.'/var/www/command/rune_shutdown' );
} else {
	echo exec( $sudoS.'/root/'.$command );
}
