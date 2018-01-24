<?php
$redis = new Redis(); 
$redis->pconnect('127.0.0.1');

include( '/srv/http/app/libs/runeaudio.php' );

wrk_mpdconf( $redis, 'writecfg' );
