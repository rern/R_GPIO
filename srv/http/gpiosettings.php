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
$gpio = file_get_contents( '/srv/http/data/gpio/gpio.json' );
$gpio = json_decode( $gpio, true );
$name = $gpio[ 'name' ];

$pin = array_keys( $name );
$on   = $gpio[ 'on' ];
$off   = $gpio[ 'off' ];
$timer = $gpio[ 'timer' ];
function optpin( $n ) {
	// omit pins: on-boot-pullup, uart
	$pinarray = array( 11, 12, 13, 15, 16, 18, 19, 21, 22, 23, 32, 33, 35, 36, 37, 38, 40 );
	$option = '';
	foreach ( $pinarray as $pin ) {
		$selected = ( $pin == $n ) ? ' selected' : '';
		$option.= '<option value='.$pin.$selected.'>'.$pin.'</option>';
	}
	return $option;
}
function optname( $pin ) {
	global $name;
	$option = '<option value="0">none</option>';
	foreach ( $name as $p => $n ) {
		$selected = ( $p == $pin ) ? ' selected' : '';
		$option.= '<option value='.$p.$selected.'>'.$n.' - '.$p.'</option>';
	}
	return $option;
}
function opttime( $n, $minimum = 1 ) {
	$option = '<option value="0">none</option>';
	foreach ( range( $minimum, 10 ) as $num ) {
		$selected = ( $num == $n ) ? ' selected' : '';
		$option.= '<option value='.$num.$selected.'>'.$num.'</option>';
	}
	return $option;
}
$htmlname = '';
foreach( range( 1, 4 ) as $i ) {
	$htmlname.= '<input id="name'.$i.'" name="name'.$i.'" type="text" class="name" value="'.$name[ $pin[ $i - 1 ] ].'">';
}
$htmlpin = '';
foreach( range( 1, 4 ) as $i ) {
	$htmlpin.= '<select id="pin'.$i.'" name="pin'.$i.'" class="pin">'.optpin( $pin[ $i - 1 ] ).'</select>';
}
$htmlon = '';
foreach( range( 1, 4 ) as $i ) {
	$htmlon.= '<select id="on'.$i.'" name="on'.$i.'" class="on">'.optname( $on[ "on$i" ] ).'</select>';
	if ( $i === 4 ) break;
	
	$htmlon.= '<select id="ond'.$i.'" name="ond'.$i.'" class="ond delay">'.opttime( $on[ "ond$i" ] ).'</select><span>sec.</span>';
}
$htmloff = '';
foreach( range( 1, 4 ) as $i ) {
	$htmloff.= '<select id="off'.$i.'" name="off'.$i.'" class="off">'.optname( $off[ "off$i" ] ).'</select>';
	if ( $i === 4 ) break;
	
	$htmloff.= '<select id="offd'.$i.'" name="offd'.$i.'" class="offd delay">'.opttime( $off[ "offd$i" ] ).'</select><span>sec.</span>';
}
?>

<body>

<div class="head">
	<i class="page-icon fa fa-gpio"></i><span class="title">GPIO</span><a href="/"><i id="close" class="fa fa-times"></i></a><i id="help" class="fa fa-question-circle"></i>
</div>

<div class="container">

<heading>Settings</heading>

<span class="help-block hide">Control <wh>GPIO</wh> connected relay module for power on /off equipments in sequence. <a href="https://github.com/rern/RuneUI_GPIO" target="_blank"><bl>More details</bl></a> <i class="fa fa-link"></i><br></span>

<div class="col-sm-10 section" id="gpio">
	<form></form> <!-- dummy for bypass 1st form not serialize -->
	<form id="gpioform">
		<div class="gpio-float-l">
			<div class="col-sm-10" id="gpio-num">
				<span class="gpio-text"><i class="fa fa-gpiopins blue"></i> &nbsp; Pin</span>
				<?=$htmlpin?>
				<span class="gpio-text"><i class="fa fa-stopwatch yellow"></i> &nbsp; Idle</span>
				<select id="timer" name="timer" class="timer">
					<?=( opttime( $timer, 2 ) )?>
				</select>
			</div>
			<div class="col-sm-10" id="gpio-name">
				<span class="gpio-text"><i class="fa fa-tag fa-lg blue"></i> &nbsp; Name</span>
				<?=$htmlname?>
				<span class="timer">&nbsp;min. to &nbsp;<i class="fa fa-power red"></i></span>
			</div>
		</div>
		<div class="gpio-float-r">
			<div class="col-sm-10">
				<span class="gpio-text"><i class="fa fa-power green"></i> &nbsp; On Sequence</span>
				<?=$htmlon?>
			</div>
			<div class="col-sm-10" style="width: 20px;">
			</div>
				<div class="col-sm-10">
					<span class="gpio-text"><i class="fa fa-power red"></i> &nbsp; Off Sequence</span>
					<?=$htmloff?>
				</div>
		</div>
	</form>
</div>
<heading>Pin reference</heading>
<span class="help-block hide">Click to show RPi GPIO pin reference.</span><br>
<span>GPIO connector: <a id="gpioimgtxt">RPi J8 &ensp;<i class="fa fa-chevron-down"></i></a><a id="fliptxt">&emsp;(Tap image to flip)</a></span><br><br>
	
<div style="position: relative">
	<img id="gpiopin" src="/img/RPi3_GPIO-flip.<?=$time?>.svg">
	<img id="gpiopin1" src="/img/RPi3_GPIO.<?=$time?>.svg">
	<a id="close-img"><i class="fa fa-times"></i></a>
</div>

</div>

<script src="/assets/js/vendor/jquery-2.2.4.min.<?=$time?>.js"></script>
<script src="/assets/js/vendor/jquery.selectric.min.<?=$time?>.js"></script>
<script src="/assets/js/banner.<?=$time?>.js"></script>
<script src="/assets/js/gpiosettings.<?=$time?>.js"></script>

</body>
</html>
