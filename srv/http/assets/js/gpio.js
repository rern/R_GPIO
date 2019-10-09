$( function() { //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

var stopwatch = '<span class="stopwatch">'
				+'<i class="fa fa-stopwatch-i fa-spin"></i>'
				+'<i class="fa fa-stopwatch-o"></i>'
				+'</span>';
var timer = false; // for 'setInterval' status check
GUI.imodedelay = 0;

function gpioOnOff() {
	$.post( 'commands.php', { bash: '/root/gpio/gpio.py state' }, function( state ) {
		GUI.gpio = state[ 0 ];
		$( '#gpio' ).toggleClass( 'on', GUI.gpio === 'ON' );
		$( '#igpio' ).toggleClass( 'hide', GUI.gpio === 'OFF' );
		if ( GUI.gpio === 'OFF' && $( '#infoOverlay' ).is( ':visible' ) ) $( '#infoX' ).click();
	}, 'json' );
}
gpioOnOff();

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
	if ( !document[ hiddenstate ] ) gpioOnOff();
} );
// nginx pushstream websocket (broadcast)
var pushstreamGPIO = new PushStream( { modes: 'websocket' } );
pushstreamGPIO.addChannel( 'gpio' );
pushstreamGPIO.connect();
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
			, message     : 'Power Off Countdown:<br><br>'
						   + stopwatch +'<white>'+ delay +'</white>'
			, oklabel     : 'Reset'
			, ok          : function() {
				$.post( 'commands.php', { bash: [
					  'killall -9 gpiotimer.py &> /dev/null'
					, '/root/gpio/gpiotimer.py &> /dev/null &'
					, 'curl -s -X POST "http://localhost/pub?id=gpio" -d \'{ "state": "RESET" }\''
				] } );
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
		var delays = [ 0 ];
		var devices = ''
		$.each( order, function( i, val ) {
			if ( i % 2 ) {
				delays.push( val );
			} else {
				devices += '<br><a id="device'+ i / 2 +'" class="'+ ( state === 'ON' ? 'gr' : '' ) +'">'+ val +'</a>';
			}
		} );
		info( {
			  icon      : 'gpio'
			, title     : 'GPIO Power '+ state
			, message   : stopwatch +' Power <wh>'+ state +'</wh>:<br>'
						+ devices
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

function countdowngpio( i, iL, delays, state ) {
	setTimeout( function() {
		$( '#device'+ i ).toggleClass( 'gr' );
		i++;
		i < iL ? countdowngpio( i, iL, delays, state ) : setTimeout( infoReset, 1000 );
	}, delays[ i ] * 1000 );
	
}

$( '#gpio' ).click( function( e ) {
	if ( $( e.target ).hasClass( 'submenu' ) ) {
		location.href = 'gpiosettings.php';
	} else {
		GUI.imodedelay = 1; // fix imode flashing on usb dac switching
		$.post( 'commands.php', { bash: '/root/gpio/gpio'+ ( GUI.gpio === 'ON' ? 'off' : 'on' ) +'.py' } );
	}
} );

} ); //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
