<?php
$onoffpy = $_GET[ 'onoffpy' ];

if ( $onoffpy === 'gpiotimer.py' ) {
	exec( '/usr/bin/sudo /usr/bin/killall -9 /root/gpiotimer.py &> /dev/null' );
	exec( '/usr/bin/sudo /root/gpiotimer.py &> /dev/null &' );
} else if ( $onoffpy === 'gpiopower.py' ) {
	$reboot = isset( $_GET[ 'reboot' ] ) ? ' reboot' : '';
	exec( '/usr/bin/sudo /root/gpiopower.py'.$reboot.' &' );
} else if ( $onoffpy === 'gpioon.py' ) {
	// set mpd.conf
	$redis = new Redis(); 
	$redis->pconnect( '127.0.0.1' );

	$ao = $redis->get( 'ao' );
	$volume = $redis->get( 'volume' );
	$mpdconf = $redis->hGetAll( 'mpdconf' );
	
	$aogpio = $redis->get( 'aogpio' );
	$volumegpio = $redis->get( 'volumegpio' );
	$mpdconfgpio = $redis->hGetAll( 'mpdconfgpio' );
	
	if ( $ao !== $aogpio || $volume !== $volumegpio || $mpdconf !== $mpdconfgpio ) {
		$acardsgpio = $redis->hGetAll( 'acardsgpio' );
		
		$redis->set( 'ao', $aogpio );
		$redis->set( 'volume', $volumegpio );
		$redis->hMset( 'acards', $acardsgpio );
		$redis->hMset( 'mpdconf', $mpdconfgpio );
		
		include( '/srv/http/app/libs/runeaudio.php' );
		
		wrk_mpdconf( $redis, 'switchao', $aogpio );
		sleep( 2 );
		wrk_mpdconf( $redis, 'restart' );
	}
} else {
	$redis = new Redis(); 
	$redis->pconnect( '127.0.0.1' );

	$ao = $redis->get( 'ao' );
	
	if ( $ao !== 'bcm2835 ALSA_1' || $ao !== 'bcm2835 ALSA_2' ) {
		include( '/srv/http/app/libs/runeaudio.php' );
		
		wrk_mpdconf( $redis, 'switchao', 'bcm2835 ALSA_1' );
		sleep( 2 );
		wrk_mpdconf( $redis, 'restart' );
	}
}

$state = exec( '/usr/bin/sudo /root/'.$onoffpy );
// response to only initiator (no broadcast)
echo $state;
