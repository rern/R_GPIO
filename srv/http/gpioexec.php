<?php
$gpio = $_GET[ 'gpio' ];
$aogpio = $_GET[ 'aogpio' ];

if ( $gpio === 'gpioon.py' ) {
	$redis = new Redis(); 
	$redis->pconnect( '127.0.0.1' );
	$aodetail = $redis->get( 'aodetail' )
	$redis->hSet( 'acards', $aogpio, $aodetail );
	$redis->set( 'ao', $aogpio )
}

$pullup = exec( '/usr/bin/sudo /root/'.$gpioonoff );
// response to only initiator (no broadcast)
echo $pullup;
