<?php $time = time(); ?>
<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<title>Rune GPIO</title>
	<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no, viewport-fit=cover">
	<meta name="apple-mobile-web-app-capable" content="yes">
	<meta name="apple-mobile-web-app-status-bar-style" content="black">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="msapplication-tap-highlight" content="no">
	<style>
		@font-face {
			font-family: enhance;
			src        : url( '/assets/fonts/enhance.<?=$time?>.woff' ) format( 'woff' ), url( '/assets/fonts/enhance.<?=$time?>.ttf' ) format( 'truetype' );
			font-weight: normal;
			font-style : normal;
		}
	</style>
	<link rel="stylesheet" href="/assets/css/selectric.<?=$time?>.css">
	<link rel="stylesheet" href="/assets/css/info.<?=$time?>.css">
	<link rel="stylesheet" href="/assets/css/gpiosettings.<?=$time?>.css">
	<link rel="icon" type="image/png" href="/assets/img/favicon-192x192.<?=$time?>.png" sizes="192x192">
</head>

<?php
/*$file = '/srv/http/data/gpio/gpio.json';
$fileopen = fopen( $file, 'r' );
$gpio = fread( $fileopen, filesize( $file ) );
fclose( $fileopen );*/
$gpio = file_get_contents( '/srv/http/data/gpio/gpio.json' );
$gpio = json_decode( $gpio, true );
$name = $gpio[ 'name' ];

$pin = array_keys( $name );
$pin1 = $pin[ 0 ];
$pin2 = $pin[ 1 ];
$pin3 = $pin[ 2 ];
$pin4 = $pin[ 3 ];
$name1 = $name[ $pin1 ];
$name2 = $name[ $pin2 ];
$name3 = $name[ $pin3 ];
$name4 = $name[ $pin4 ];

$on   = $gpio[ 'on' ];
$onlist = [ 'on1', 'ond1', 'on2', 'ond2', 'on3', 'ond3', 'on4' ];
foreach( $onlist as $o ) $$o = $on[ $o ];
$off   = $gpio[ 'off' ];
$offlist = [ 'off1', 'offd1', 'off2', 'offd2', 'off3', 'offd3', 'off4' ];
foreach( $offlist as $o ) $$o = $off[ $o ];

$timer = $gpio[ 'timer' ];
function optpin( $n ) {
	// omit pins: on-boot-pullup, uart
	$pinarray = array( 11, 12, 13, 15, 16, 18, 19, 21, 22, 23, 32, 33, 35, 36, 37, 38, 40 );
	$option = '';
	foreach ( $pinarray as $pin ) {
		$selected = ( $pin == $n ) ? ' selected' : '';
		$option.= '<option value='.$pin.$selected.'>'.$pin.'</option>';
	}
	echo $option;
}
function optname( $pin ) {
	global $name;
	$option = '<option value="0">none</option>';
	foreach ( $name as $p => $n ) {
		$selected = ( $p == $pin ) ? ' selected' : '';
		$option.= '<option value='.$p.$selected.'>'.$n.' - '.$p.'</option>';
	}
	echo $option;
}
function opttime( $n, $minimum = 1 ) {
	$option = '<option value="0">none</option>';
	foreach ( range( $minimum, 10 ) as $num ) {
		$selected = ( $num == $n ) ? ' selected' : '';
		$option.= '<option value='.$num.$selected.'>'.$num.'</option>';
	}
	echo $option;
}
?>

<body>

<div class="container">
<i class="close-root fa fa-times"></i>
<h1><i class="fa fa-gpio gr"></i>&nbsp; GPIO</h1>
<heading>Settings</heading>
<form class="form-horizontal">

<p>
	Control 'GPIO' connected relay module for power on /off equipments in sequence.<br>
	Pin number: <a id="gpioimgtxt">RPi J8 &ensp;<i class="fa fa-chevron-down"></i></a><a id="fliptxt">&emsp;(Tap image to flip)</a>
</p>
<div style="position: relative">
<img id="gpiopin" src="/img/RPi3_GPIO-flip.<?=$time?>.svg">
<img id="gpiopin1" src="/img/RPi3_GPIO.<?=$time?>.svg">
<a id="close-img"><i class="fa fa-times"></i></a>
</div>
	<div class="col-sm-10 section" id="gpio">
		<form></form> <!-- dummy for bypass 1st form not serialize -->
		<form id="gpioform">
			<div class="gpio-float-l">
				<div class="col-sm-10" id="gpio-num">
					<span class="gpio-text"><i class="fa fa-gpiopins blue"></i> &nbsp; Pin</span>
					<select id="pin1" name="pin1" class="pin">
						<?php optpin( $pin1 )?>
					</select>
					<select id="pin2" name="pin2" class="pin">
						<?php optpin( $pin2 )?>
					</select>
					<select id="pin3" name="pin3" class="pin">
						<?php optpin( $pin3 )?>
					</select>
					<select id="pin4" name="pin4" class="pin">
						<?php optpin( $pin4 )?>
					</select>
					<span class="gpio-text"><i class="fa fa-stopwatch yellow"></i> &nbsp; Idle</span>
					<select id="timer" name="timer" class="timer">
						<?php opttime( $timer, 2 )?>
					</select>
				</div>
				<div class="col-sm-10" id="gpio-name">
					<span class="gpio-text"><i class="fa fa-tag fa-lg blue"></i> &nbsp; Name</span>
					<input id="name1" name="name1" type="text" class="form-control input-lg name" value="<?=$name1?>">
					<input id="name2" name="name2" type="text" class="form-control input-lg name" value="<?=$name2?>">
					<input id="name3" name="name3" type="text" class="form-control input-lg name" value="<?=$name3?>">
					<input id="name4" name="name4" type="text" class="form-control input-lg name" value="<?=$name4?>">
					<span class="timer">&nbsp;min. to &nbsp;<i class="fa fa-power red"></i></span>
				</div>
			</div>
			<div class="gpio-float-r">
				<div class="col-sm-10">
					<span class="gpio-text"><i class="fa fa-power green"></i> &nbsp; On Sequence</span>
					<select id="on1" name="on1" class="on">
						<?php optname( $on1 )?>
					</select>
					<select id="ond1" name="ond1" class="ond delay">
						<?php opttime( $ond1 )?>
					</select><span>sec.</span>
					<select id="on2" name="on2" class="on">
						<?php optname( $on2 )?>
					</select>
					<select id="ond2" name="ond2" class="ond delay">
						<?php opttime( $ond2 )?>
					</select><span>sec.</span>
					<select id="on3" name="on3" class="on">
						<?php optname( $on3 )?>
					</select>
					<select id="ond3" name="ond3" class="ond delay">
						<?php opttime( $ond3 )?>
					</select><span>sec.</span>
					<select id="on4" name="on4" class="on">
						<?php optname( $on4 )?>
					</select>
				</div>
				<div class="col-sm-10" style="width: 20px;">
				</div>
					<div class="col-sm-10">
						<span class="gpio-text"><i class="fa fa-power red"></i> &nbsp; Off Sequence</span>
						<select id="off1" name="off1" class="off">
							<?php optname( $off1 )?>
						</select>
						<select id="offd1" name="offd1" class="offd delay">
							<?php opttime( $offd1 )?>
						</select><span>sec.</span>
						<select id="off2" name="off2" class="off">
							<?php optname( $off2 )?>
						</select>
						<select id="offd2" name="offd2" class="offd delay">
							<?php opttime( $offd2 )?>
						</select><span>sec.</span>
						<select id="off3" name="off3" class="off">
							<?php optname( $off3 )?>
						</select>
						<select id="offd3" name="offd3" class="offd delay">
							<?php opttime( $offd3 )?>
						</select><span>sec.</span>
						<select id="off4" name="off4" class="off">
							<?php optname( $off4 )?>
						</select>
					</div>
			</div>
		</form>
	</div>

</form>
</div>

<script src="/assets/js/vendor/jquery-2.2.4.min.<?=$time?>.js"></script>
<script src="/assets/js/vendor/jquery.selectric.min.<?=$time?>.js"></script>
<script src="/assets/js/banner.<?=$time?>.js"></script>
<script src="/assets/js/gpiosettings.<?=$time?>.js"></script>

</body>
</html>
