<?php
$onoffpy = $_GET[ 'onoffpy' ];

// set mpd.conf
if ( $onoffpy === 'gpioon.py' ) {
	$redis = new Redis(); 
	$redis->pconnect( '127.0.0.1' );
	
	$aogpio = $redis->get( 'aogpio' );
	$volumegpio = $redis->get( 'volume' );
	$acardsgpio = $redis->hGetAll( 'acardsgpio' );
	$mpdconfgpio = $redis->hGetAll( 'mpdconfgpio' );
	
	$redis->set( 'ao', $aogpio );
	$redis->set( 'volume', $volumegpio );
	$redis->hMset( 'acards', $acardsgpio );
	$redis->hMset( 'mpdconf', $mpdconfgpio );
	
	include( '/srv/http/app/libs/runeaudio.php' );
	
	wrk_mpdconf( $redis, 'writecfg' );
	sysCmd( 'systemctl restart mpd' );
}

$pullup = exec( '/usr/bin/sudo /root/'.$onoffpy );
// response to only initiator (no broadcast)
echo $pullup;
