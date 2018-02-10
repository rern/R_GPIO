<?php
$onoffpy = $_GET[ 'onoffpy' ];

if ( $onoffpy === 'gpiotimer.py' ) {
	exec( '/usr/bin/sudo /usr/bin/killall -9 /root/gpiotimer.py &> /dev/null' );
	exec( '/usr/bin/sudo /root/gpiotimer.py &> /dev/null &' );
	die();
}

if ( $onoffpy === 'gpioon.py' ) {
	$redis = new Redis(); 
	$redis->pconnect( '127.0.0.1' );
	$redis->set( 'asound0', shell_exec( '/usr/bin/cat /proc/asound/cards' ) ); // save asound before power on
}

echo exec( '/usr/bin/sudo /root/'.$onoffpy );

if ( $onoffpy === 'gpioon.py' ) {
	// set mpd.conf
	$mpdconf = $redis->hGetAll( 'mpdconf' );
	$mpdconfgpio = $redis->hGetAll( 'mpdconfgpio' );
	
	if ( $mpdconf === $mpdconfgpio ) die();
	
	$redis->set( 'ao0', $redis->get( 'ao' ) ); // save current acard before switch
	$aogpio = $redis->get( 'aogpio' );
	$volumegpio = $redis->get( 'volumegpio' );
	$redis->set( 'ao', $aogpio );
	$redis->set( 'volume', $volumegpio );
	foreach ( $mpdconfgpio as $key => $value ) {
		$redis->hSet( 'mpdconf', $key, $value );
	}
	
	include( '/srv/http/app/libs/runeaudio.php' );
	
	wrk_audioOutput($redis, 'refresh');         // refresh acards list: cat /proc/asound/cards
	wrk_mpdconf( $redis, 'switchao', $aogpio ); // select acard + writecfg
	wrk_mpdconf( $redis, 'restart' );           // restart mpd
} else if ( $onoffpy === 'gpiooff.py' ) {
	$redis = new Redis(); 
	$redis->pconnect( '127.0.0.1' );
	$asound0 = $redis->get( 'asound0' );
	$redis->del( 'asound0' );
	$asound1 = shell_exec( '/usr/bin/cat /proc/asound/cards' );
	
	if ( $asound0 === $asound1 ) die();

	$ao0 = $redis->get( 'ao0' );
	$redis->del( 'ao0' );

	wrk_audioOutput($redis, 'refresh');
	wrk_mpdconf( $redis, 'switchao', $ao0 );
	wrk_mpdconf( $redis, 'restart' );
}
