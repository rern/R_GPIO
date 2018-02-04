<?php
$redis = new Redis(); 
$redis->pconnect( "127.0.0.1" );

$aogpio = $redis->get( "ao" );
$volume = $redis->get( "volume" );
$acards = $redis->hGetAll( "acards" );
$mpdconf = $redis->hGetAll( "mpdconf" );

$redis->set( "aogpio", $aogpio );
$redis->set( "volumegpio", $volume );
$redis->hMset( "acardsgpio", $acards );
$redis->hMset( "mpdconfgpio", $mpdconf );
