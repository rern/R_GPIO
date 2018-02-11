<?php
$redis = new Redis(); 
$redis->pconnect( '127.0.0.1' );

if ( isset( $_GET[ 'udac' ] ) ) {
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
	
	$ao = $redis->get( 'ao' );
	if ( !$acards[ $ao ] ) {
		$redis->set( 'ao', 'bcm2835 ALSA_1' );
		wrk_mpdconf( $redis, 'switchao', 'bcm2835 ALSA_1' );
		wrk_mpdconf( $redis, 'restart' );
	}
	
	die();
}

$redis->set( 'enablegpio', $_POST[ 'enable' ] );

if ( isset( $_GET[ 'ao' ] ) ) {
	$aogpio = $redis->get( 'ao' );
	$volume = $redis->get( 'volume' );
	$mpdconf = $redis->hGetAll( 'mpdconf' );
	
	$redis->set( 'aogpio', $aogpio );
	$redis->set( 'volumegpio', $volume );
	foreach ( $mpdconf as $key => $value ) {
		$redis->hSet( 'mpdconfgpio', $key, $value );
	}
	
	die();
}

$gpio = array(
	  'pin'    => array(
		  'pin1'   => $_POST[ 'pin1' ]
		, 'pin2'   => $_POST[ 'pin2' ]
		, 'pin3'   => $_POST[ 'pin3' ]
		, 'pin4'   => $_POST[ 'pin4' ]
	)
	, 'name'   => array(
		  'name1'  => $_POST[ 'name1' ]
		, 'name2'  => $_POST[ 'name2' ]
		, 'name3'  => $_POST[ 'name3' ]
		, 'name4'  => $_POST[ 'name4' ]
	)
	, 'on'     => array(
		  'on1'    => $_POST[ 'on1' ]
		, 'ond1'   => $_POST[ 'ond1' ]
		, 'on2'    => $_POST[ 'on2' ]
		, 'ond2'   => $_POST[ 'ond2' ]
		, 'on3'    => $_POST[ 'on3' ]
		, 'ond3'   => $_POST[ 'ond3' ]
		, 'on4'    => $_POST[ 'on4' ]
	)
	, 'off'    => array(
		  'off1'   => $_POST[ 'off1' ]
		, 'offd1'  => $_POST[ 'offd1' ]
		, 'off2'   => $_POST[ 'off2' ]
		, 'offd2'  => $_POST[ 'offd2' ]
		, 'off3'   => $_POST[ 'off3' ]
		, 'offd3'  => $_POST[ 'offd3' ]
		, 'off4'   => $_POST[ 'off4' ]
	)
	, 'timer'  => array( 'timer'  => $_POST[ 'timer' ] )
);
$jsonfile = fopen( '/srv/http/gpio.json', 'w' );
$set = fwrite( $jsonfile, json_encode( $gpio ) );
fclose( $jsonfile );
echo $set;
