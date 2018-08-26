$( function() { //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

var stopwatch = '<span class="stopwatch fa-stack fa-2x">'
				+'<i class="fa fa-stopwatch-i fa-spin fa-stack-1x"></i>'
				+'<i class="fa fa-stopwatch-o fa-stack-1x"></i>'
				+'</span>'
var timer = false; // for 'setInterval' status check
GUI.imodedelay = 0;

function gpioOnOff() {
	$.get( 'gpioexec.php?command=gpio.py state', function( state ) {
		gpiostate = state;
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
	if ( document[ hiddenstate ] ) {
		pushstreamGPIO.disconnect();
	} else {
		gpioOnOff();
		if ( !timer ) $( '#infoX' ).click();
		pushstreamGPIO.connect();
	}
} );
// nginx pushstream websocket (broadcast)
var pushstreamGPIO = new PushStream( {
	host: window.location.hostname,
	port: window.location.port,
	modes: GUI.mode
} );
pushstreamGPIO.addChannel( 'gpio' );
pushstreamGPIO.onmessage = function( response ) { // on receive broadcast
	// json from python requests.post( 'url' json={...} ) is in response[ 0 ]
	var state = response[ 0 ].state;
	var delay = response[ 0 ].delay;
	if ( timer ) { // must clear before pnotify can remove
		clearInterval( timer );
		timer = false;
	}
	if ( state == 'RESET' ) {
		$( '#infoX' ).click();
	} else if ( state == 'IDLE' ) {
		info( {
			  icon        : stopwatch
			, title       : 'GPIO Timer'
			, message     : 'Idle Off Countdown:<br>'+ stopwatch +'<white>'+ delay +'</white>'
			, cancellabel : 'Hide'
			, cancel      : 1
			, oklabel     : 'Reset'
			, ok          : function() {
				$.get( 'gpioexec.php?command=timer' );
			}
		} );
		timer = setInterval( function() {
			if ( delay == 1 ) {
				GUI.imodedelay = 1;
				$( '#infoOverlay' ).hide();
				clearInterval( timer );
			}
			$( '#infoMessage white' ).text( delay-- );
		}, 1000 );
	} else {
		PNotify.removeAll();
		new PNotify( {
			  icon    : ( state != 'FAILED !' ) ? 'fa fa-cog fa-spin fa-lg' : 'fa fa-warning fa-lg'
			, title   : 'GPIO'
			, text    : 'Powering '+ state +' ...'
			, delay   : delay * 1000
			, addclass: 'pnotify_custom'
		} );
		setTimeout( function() {  // no 'after_close' in this version of pnotify
			gpioOnOff();
			if ( state == 'OFF' ) $( '#infoX' ).click();
		}, delay * 1000 );
		
		setTimeout( function() {
			GUI.imodedelay = 0;
		}, 5000 );
	}
}
pushstreamGPIO.connect();

$( '#gpio' ).on( 'taphold', function() {
	$( 'body' ).append( '\
		<form id="formtemp" action="gpiosettings.php" method="post">\
			<input type="hidden" name="addonswoff" value="'+ $( '#addonswoff' ).val() +'">\
			<input type="hidden" name="addonsttf" value="'+ $( '#addonsttf' ).val() +'">\
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
	$.get( 'gpioexec.php?command='+ ( gpiostate === 'ON' ? 'gpiooff.py' : 'gpioon.py' ) );
} );

$( '#syscmd-poweroff, #syscmd-reboot' ).off( 'click' ).on( 'click', function() {
	$.get( 'gpioexec.php?command='+ ( this.id == 'syscmd-reboot' ? ' reboot' : 'poweroff' ) );
	toggleLoader();
} );

} ); //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
