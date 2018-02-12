<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>RuneGPIO</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-status-bar-style" content="black">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="msapplication-tap-highlight" content="no" />
    <link rel="stylesheet" href="assets/css/runeui.css">
    <link rel="stylesheet" href="assets/css/addonsinfo.css">
    <link rel="stylesheet" href="assets/css/gpiosettings.css">
    <link rel="shortcut icon" href="assets/img/favicon.ico">
</head>

<?php
$file = '/srv/http/gpio.json';
$fileopen = fopen( $file, 'r' );
$gpio = fread( $fileopen, filesize( $file ) );
fclose( $fileopen );
$gpio = json_decode( $gpio, true );

$enable = $gpio[ 'enable' ][ 'enable' ];

$pin  = $gpio[ 'pin' ];
$pin1 = $pin[ 'pin1' ];
$pin2 = $pin[ 'pin2' ];
$pin3 = $pin[ 'pin3' ];
$pin4 = $pin[ 'pin4' ];
$pincount = ( $pin1 == 0 ? 0 : 1 ) + ( $pin2 == 0 ? 0 : 1 ) + ( $pin3 == 0 ? 0 : 1 ) + ( $pin4 == 0 ? 0 : 1 );

$name  = $gpio[ 'name' ];
$name1 = $name[ 'name1' ];
$name2 = $name[ 'name2' ];
$name3 = $name[ 'name3' ];
$name4 = $name[ 'name4' ];

$on   = $gpio[ 'on' ];
$on1  = $on[ 'on1' ];
$ond1 = $on[ 'ond1' ];
$on2  = $on[ 'on2' ];
$ond2 = $on[ 'ond2' ];
$on3  = $on[ 'on3' ];
$ond3 = $on[ 'ond3' ];
$on4  = $on[ 'on4' ];

$off   = $gpio[ 'off' ];
$off1  = $off[ 'off1' ];
$offd1 = $off[ 'offd1' ];
$off2  = $off[ 'off2' ];
$offd2 = $off[ 'offd2' ];
$off3  = $off[ 'off3' ];
$offd3 = $off[ 'offd3' ];
$off4  = $off[ 'off4' ];

$timer = $gpio[ 'timer' ][ 'timer' ];

function optpin( $n ) {
	// omit pins: on-boot-pullup, uart, I2S
	$pinarray = array( 11,13,15,16,18,19,21,22,23,32,33,36,37 );
	$option = '';
	foreach ( $pinarray as $pin ) {
		$selected = ( $pin == $n ) ? ' selected' : '';
		$option.= '<option value='.$pin.$selected.'>'.$pin.'</option>';
	}
	echo $option;
}
$parray = array(
	  $pin1 => $name1
	, $pin2 => $name2
	, $pin3 => $name3
	, $pin4 => $name4
);
function optname( $n ) {
	global $parray;
	$option = '<option value="0">none</option>';
	foreach ( $parray as $pin => $name ) {
		$selected = ( $pin == $n ) ? ' selected' : '';
		$option.= '<option value='.$pin.$selected.'>'.$name.' - '.$pin.'</option>';
	}
	echo $option;
}
function opttime( $n, $min ) {
	$min = !isset( $min ) ? 1 : $min;
	$option = '<option value="0">none</option>';
	foreach ( range( $min, 10 ) as $num ) {
		$selected = ( $num == $n ) ? ' selected' : '';
		$option.= '<option value='.$num.$selected.'>'.$num.'</option>';
	}
	echo $option;
}
?>

<body>

<div class="container">
<h1>GPIO</h1><a id="close"><i class="fa fa-times fa-2x"></i></a>
<legend>Settings</legend>
<form class="form-horizontal">

<p>
	Control 'GPIO' connected relay module for power on /off equipments in sequence.<br>
	Pin number: <a id="gpioimgtxt" style="cursor: pointer">RPi J8 &ensp;<i class="fa fa-chevron-circle-down fa-lg"></i></a>
</p>
<img src="assets/img/RPi3_GPIO.svg" style="display: none; margin-bottom: 10px; width: 100%; max-width: 600px; background: #ffffff;">
<div id="divgpio" class="boxed-group">
	<div class="form-group">
		<label for="gpio" class="col-sm-2 control-label">Enable</label>
		<div class="col-sm-10">
			<label class="switch-light well" onclick="">
				<input id="gpio-enable" type="checkbox" <?=$enable == 1 ? 'value="1" checked="checked"' : 'value="0"';?>>
				<span><span>OFF</span><span>ON</span></span><a class="btn btn-primary"></a>
			</label>
		</div>
	</div>
	<div class="form-group" <?=$enable == 0 ? 'style="display:none"' : ''?> id="gpio-group">
		<div class="col-sm-10 section" id="gpio">
			<form></form> <!-- dummy for bypass 1st form not serialize -->
			<form id="gpioform">
				<div class="gpio-float-l">
					<div class="col-sm-10" id="gpio-num">
						<span class="gpio-text"><i class="fa fa-ellipsis-v fa-lg blue"></i> &nbsp; Pin</span>
						<select id="pin1" name="pin1" class="selectpicker pin">
							<?php optpin( $pin1 )?>
						</select>
						<select id="pin2" name="pin2" class="selectpicker pin">
							<?php optpin( $pin2 )?>
						</select>
						<select id="pin3" name="pin3" class="selectpicker pin">
							<?php optpin( $pin3 )?>
						</select>
						<select id="pin4" name="pin4" class="selectpicker pin">
							<?php optpin( $pin4 )?>
						</select>
						<span class="gpio-text"><i class="fa fa-clock-o fa-lg yellow"></i> &nbsp; Idle</span>
						<select id="timer" name="timer" class="selectpicker timer">
							<?php opttime( $timer, 2 )?>
						</select>
					</div>
					<div class="col-sm-10" id="gpio-name">
						<span class="gpio-text"><i class="fa fa-tag fa-lg blue"></i> &nbsp; Name</span>
						<input id="name1" name="name1" type="text" class="form-control osk-trigger input-lg name" value="<?=$name1?>">
						<input id="name2" name="name2" type="text" class="form-control osk-trigger input-lg name" value="<?=$name2?>">
						<input id="name3" name="name3" type="text" class="form-control osk-trigger input-lg name" value="<?=$name3?>">
						<input id="name4" name="name4" type="text" class="form-control osk-trigger input-lg name" value="<?=$name4?>">
						<br>
						<span class="timer">&nbsp;min. to &nbsp;<i class="fa fa-power-off red"></i> &nbsp;Off</span>
					</div>
				</div>
				<div class="gpio-float-r">
					<div class="col-sm-10">
						<span class="gpio-text"><i class="fa fa-power-off fa-lg green"></i> &nbsp; On Sequence</span>
						<select id="on1" name="on1" class="selectpicker on">
							<?php optname( $on1 )?>
						</select>
						<select id="ond1" name="ond1" class="selectpicker ond delay">
							<?php opttime( $ond1 )?>
						</select> &nbsp; sec.
						<select id="on2" name="on2" class="selectpicker on">
							<?php optname( $on2 )?>
						</select>
						<select id="ond2" name="ond2" class="selectpicker ond delay">
							<?php opttime( $ond2 )?>
						</select> &nbsp; sec.
						<select id="on3" name="on3" class="selectpicker on">
							<?php optname( $on3 )?>
						</select>
						<select id="ond3" name="ond3" class="selectpicker ond delay">
							<?php opttime( $ond3 )?>
						</select> &nbsp; sec.
						<select id="on4" name="on4" class="selectpicker on">
							<?php optname( $on4 )?>
						</select>
					</div>
					<div class="col-sm-10" style="width: 20px;">
					</div>
						<div class="col-sm-10">
							<span class="gpio-text"><i class="fa fa-power-off fa-lg red"></i> &nbsp; Off Sequence</span>
							<select id="off1" name="off1" class="selectpicker off">
								<?php optname( $off1 )?>
							</select>
							<select id="offd1" name="offd1" class="selectpicker offd delay">
								<?php opttime( $offd1 )?>
							</select> &nbsp; sec.
							<select id="off2" name="off2" class="selectpicker off">
								<?php optname( $off2 )?>
							</select>
							<select id="offd2" name="offd2" class="selectpicker offd delay">
								<?php opttime( $offd2 )?>
							</select> &nbsp; sec.
							<select id="off3" name="off3" class="selectpicker off">
								<?php optname( $off3 )?>
							</select>
							<select id="offd3" name="offd3" class="selectpicker offd delay">
								<?php opttime( $offd3 )?>
							</select> &nbsp; sec.
							<select id="off4" name="off4" class="selectpicker off">
								<?php optname( $off4 )?>
							</select>
							<a id="gpiosave" class="btn btn-primary">Save</a>
						</div>
				</div>
			</form>
		</div>
	</div>
</div>

</form>
</div>

<script src="assets/js/vendor/jquery-2.1.0.min.js"></script>
<script src="assets/js/vendor/bootstrap.min.js"></script>
<script src="assets/js/vendor/bootstrap-select-1.12.1.min.js"></script>
<script src="assets/js/vendor/pnotify.custom.min.js"></script>
<script src="assets/js/addonsinfo.js"></script>
<script src="assets/js/gpiosettings.js"></script>

</body>
</html>
