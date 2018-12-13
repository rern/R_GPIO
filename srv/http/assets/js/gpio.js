$( function() { //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

var stopwatch = '<span id="stopwatch" class="fa-stack">'
				+'<i class="fa fa-stopwatch-i fa-spin fa-stack-2x"></i>'
				+'<i class="fa fa-stopwatch-o fa-stack-2x"></i>'
				+'</span>'
var timer = false; // for 'setInterval' status check
GUI.imodedelay = 0;

function gpioOnOff() {
	$.get( 'gpioexec.php?command=gpio.py state', function( state ) {
		GUI.gpio = state;
		$( '#gpio' ).toggleClass( 'active', state === 'ON' );
		$( '#igpio' ).toggleClass( 'hide', state === 'OFF' );
	}, 'text' );
}
gpioOnOff();

if ( !timer ) $( '#infoX' ).click();

if ( 'hidden' in document ) {
	var visibilityevent = 'visibilitychange';
	var hiddenstate = 'hidden';
} else { // cross-browser document.visibilityState must be prefixed
	var prefixes = [ 'webkit', 'moz', 'ms', 'o' ];
	for ( var i = 0; i < 4; i++ ) {
		var p = prefixes[ i ];
		if ( p +'Hidden' in document ) {
			var visibilityevent = p +'visibilitychange';
			var hiddenstate = p +'Hidden';
			break;
		}
	}
}
document.addEventListener( visibilityevent, function() {
	if ( !document[ hiddenstate ] ) {
		gpioOnOff();
		if ( !timer ) $( '#infoX' ).click();
	}
} );
// nginx pushstream websocket (broadcast)
var pushstreamGPIO = new PushStream( { modes: 'websocket' } );
pushstreamGPIO.addChannel( 'gpio' );
pushstreamGPIO.onmessage = function( response ) { // on receive broadcast
	// json from python requests.post( 'url' json={...} ) is in response[ 0 ]
	var response = response[ 0 ];
	var state = response.state;
	GUI.gpio = state;
	var delay = response.delay;
	if ( timer ) { // must clear before pnotify can remove
		clearInterval( timer );
		timer = false;
	}
	if ( state == 'RESET' ) {
		$( '#infoX' ).click();
	} else if ( state == 'IDLE' ) {
		info( {
			  icon        : 'gpio'
			, title       : 'GPIO Idle Timer'
			, message     : 'Power Off Countdown:<br><br>'+ stopwatch +'&emsp;<white>'+ delay +'</white>'
			, cancellabel : 'Hide'
			, cancel      : 1
			, oklabel     : 'Reset'
			, ok          : function() {
				$.get( 'gpioexec.php?command=timer' );
			}
		} );
		timer = setInterval( function() {
			if ( delay === 1 ) {
				GUI.imodedelay = 1;
				$( '#infoX' ).click();
				clearInterval( timer );
			}
			$( '#infoMessage white' ).text( delay-- );
		}, 1000 );
	} else {
		var order = response.order;
		var delays = [];
		var devices = ''
		$.each( order, function( i, val ) {
			if ( i % 2 ) {
				delays.push( val );
			} else {
				var color = state === 'ON' ? 'gr' : 'wh'
				devices += '<br><'+ color +' id="device'+ i / 2 +'">'+ val +'</'+ color +'>';
			}
		} );
		info( {
			  icon      : ( state != 'FAILED !' ) ? 'gpio' : 'warning'
			, title     : 'GPIO Power '+ state
			, message   : stopwatch +'&ensp;Power <wh>'+ state +'</wh>:<br>'+ devices
			, autoclose : ( delay + 4 ) * 1000
			, nobutton  : 1
		} );
		var iL = delays.length;
		var i = 0
		countdowngpio( i, iL, delays, state );
		
		setTimeout( function() {
			gpioOnOff();
		}, delay * 1000 );
		
		setTimeout( function() {
			GUI.imodedelay = 0;
		}, 5000 );
	}
}
pushstreamGPIO.connect();

function countdowngpio( i, iL, delays, state ) {
	var color = state === 'ON' ? '#e0e7ee' : '#587ca0'
	$( '#device'+ i ).css( 'color', color );
	setTimeout( function() {
		$( '#device'+ i ).css( 'color', color );
		i++;
		if ( i <= iL ) countdowngpio( i, iL, delays, state );
	}, delays[ i ] * 1000 );
	
}

$( '#gpio' ).on( 'taphold', function() {
	$( 'body' ).append( '\
		<form id="formtemp" action="gpiosettings.php" method="post">\
			<input type="hidden" name="favicon" value="'+ $( '#favicon' ).val() +'">\
			<input type="hidden" name="addonswoff" value="'+ $( '#addonswoff' ).val() +'">\
			<input type="hidden" name="addonsttf" value="'+ $( '#addonsttf' ).val() +'">\
			<input type="hidden" name="bootstrapmincss" value="'+ $( '#bootstrapmincss' ).val() +'">\
			<input type="hidden" name="bootstrapselectmincss" value="'+ $( '#bootstrapselectmincss' ).val() +'">\
			<input type="hidden" name="addonsinfocss" value="'+ $( '#addonsinfocss' ).val() +'">\
			<input type="hidden" name="gpiosettingscss" value="'+ $( '#gpiosettingscss' ).val() +'">\
			<input type="hidden" name="addonsinfojs" value="'+ $( '#addonsinfojs' ).val() +'">\
			<input type="hidden" name="gpiosettingsjs" value="'+ $( '#gpiosettingsjs' ).val() +'">\
			<input type="hidden" name="gpiopin" value="'+ $( '#gpiopin' ).val() +'">\
		</form>\
	' );
	$( '#formtemp' ).submit();
} ).click( function() {
	GUI.imodedelay = 1; // fix imode flashing on usb dac switching
	$( '#settings' ).addClass( 'hide' );
	$.get( 'gpioexec.php?command='+ ( GUI.gpio === 'ON' ? 'gpiooff.py' : 'gpioon.py' ) );
} );

$( '#syscmd-poweroff, #syscmd-reboot' ).off( 'click' ).on( 'click', function() {
	$.get( 'gpioexec.php?command='+ ( this.id == 'syscmd-reboot' ? ' reboot' : 'poweroff' ) );
	toggleLoader();
} );

} ); //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
