<?php
$gpio = array(
	 'name'   => array(
		  $_POST[ 'pin1' ] => $_POST[ 'name1' ]
		, $_POST[ 'pin2' ] => $_POST[ 'name2' ]
		, $_POST[ 'pin3' ] => $_POST[ 'name3' ]
		, $_POST[ 'pin4' ] => $_POST[ 'name4' ]
	)
	, 'on'    => array(
		  'on1'    => $_POST[ 'on1' ]
		, 'ond1'   => $_POST[ 'ond1' ]
		, 'on2'    => $_POST[ 'on2' ]
		, 'ond2'   => $_POST[ 'ond2' ]
		, 'on3'    => $_POST[ 'on3' ]
		, 'ond3'   => $_POST[ 'ond3' ]
		, 'on4'    => $_POST[ 'on4' ]
	)
	, 'off'   => array(
		  'off1'   => $_POST[ 'off1' ]
		, 'offd1'  => $_POST[ 'offd1' ]
		, 'off2'   => $_POST[ 'off2' ]
		, 'offd2'  => $_POST[ 'offd2' ]
		, 'off3'   => $_POST[ 'off3' ]
		, 'offd3'  => $_POST[ 'offd3' ]
		, 'off4'   => $_POST[ 'off4' ]
	)
	, 'timer' => $_POST[ 'timer' ]
);
$jsonfile = fopen( '/srv/http/gpio.json', 'w' );
$set = fwrite( $jsonfile, json_encode( $gpio, JSON_NUMERIC_CHECK ) );
fclose( $jsonfile );
echo $set;
