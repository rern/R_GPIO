<?php
$gpio = $_GET[ 'gpio' ];

if ( $gpio === 'gpioon.py' ) {
	$redis = new Redis(); 
	$redis->pconnect( '127.0.0.1' );
	$aogpio = $redis->get( 'aogpio' )
	$aodetail = $redis->get( 'aodetail' )
	$redis->hSet( 'acards', $aogpio, $aodetail );
	$redis->set( 'ao', $aogpio )
	
	include( '/srv/http/app/libs/runeaudio.php' );
	
	wrk_mpdconf( $redis, 'writecfg' );
}

$pullup = exec( '/usr/bin/sudo /root/'.$gpioonoff );
// response to only initiator (no broadcast)
echo $pullup;
