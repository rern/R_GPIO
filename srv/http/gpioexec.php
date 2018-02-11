<?php
$onoffpy = $_GET[ 'onoffpy' ];

if ( $onoffpy === 'gpiotimer.py' ) {
	exec( '/usr/bin/sudo /usr/bin/killall -9 /root/gpiotimer.py &> /dev/null' );
	exec( '/usr/bin/sudo /root/gpiotimer.py &> /dev/null &' );
	die();
}

echo exec( '/usr/bin/sudo /root/'.$onoffpy );

if ( $onoffpy !== 'gpioon.py' ) die();

$redis = new Redis(); 
$redis->pconnect( '127.0.0.1' );

$ao = $redis->get( 'ao' );
$aogpio = $redis->get( 'aogpio' );

if ( $ao === $aogpio ) die();

$volumegpio = $redis->get( 'volumegpio' );
$mpdconfgpio = $redis->hGetAll( 'mpdconfgpio' );

$redis->set( 'ao', $aogpio );
$redis->set( 'volume', $volumegpio );
foreach ( $mpdconfgpio as $key => $value ) {
	$redis->hSet( 'mpdconf', $key, $value );

include( '/srv/http/app/libs/runeaudio.php' );

wrk_audioOutput($redis, 'refresh'); // refresh acards list: cat /proc/asound/cards

// fix hw:0,N - missing N after wrk_audioOutput($redis, 'refresh')
$acards = $redis->hGetAll( 'acards' );
foreach ( $acards as $key => $value ) {
	preg_match( '/"id":"."/', $value, $match );
	$id = preg_replace( '/"id":"(.)"/', '${1}', $match[ 0 ] );
	$subdevice = $id ? $id - 1 : 0;
	$value1 = preg_replace( '/(hw:.,)/', '${1}'.$subdevice, $value );
	$redis->hSet( 'acards', $key, $value1 );
}
wrk_mpdconf( $redis, 'switchao', $aogpio ); // select acard + writecfg
wrk_mpdconf( $redis, 'restart' );           // restart mpd
