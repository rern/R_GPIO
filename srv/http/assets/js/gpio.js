$( function() { //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

var stopwatch = '<span id="stopwatch" class="fa-stack">'
				+'<i class="fa fa-stopwatch-i fa-spin fa-stack-2x"></i>'
				+'<i class="fa fa-stopwatch-o fa-stack-2x"></i>'
				+'</span>';
var timer = false; // for 'setInterval' status check
GUI.imodedelay = 0;

function gpioOnOff() {
	$.get( 'gpioexec.php?command=gpio.py state', function( state ) {
		GUI.gpio = state;
		$( '#gpio' ).toggleClass( 'on', state === 'ON' );
		$( '#igpio' ).toggleClass( 'hide', state === 'OFF' );
		if ( $( '#infoIcon i.fa-gpio' ).length && state === 'OFF' ) $( '#infoX' ).click();
	}, 'text' );
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
			, message     : 'Power Off Countdown:<br><br>'+ stopwatch +'&emsp;<white>'+ delay +'</white>'
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
		var delays = [ 0 ];
		var devices = ''
		$.each( order, function( i, val ) {
			if ( i % 2 ) {
				delays.push( val );
			} else {
				var color = state === 'ON' ? '#7795b4' : '#e0e7ee'
				devices += '<br><a id="device'+ i / 2 +'" style="color: '+ color +'">'+ val +'</a>';
			}
		} );
		info( {
			  icon      : ( state != 'FAILED !' ) ? 'gpio' : 'warning'
			, title     : 'GPIO Power '+ state
			, message   : stopwatch +'Power <wh>'+ state +'</wh>:<br>'+ devices
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
	var color = state === 'ON' ? '#e0e7ee' : '#7795b4';
	setTimeout( function() {
		$( '#device'+ i ).css( 'color', color );
		i++;
		i < iL ? countdowngpio( i, iL, delays, state ) : setTimeout( function() { $( '#infoX' ).click() }, 1000 );
	}, delays[ i ] * 1000 );
	
}

$( '#gpio' ).click( function( e ) {
	if ( $( e.target ).hasClass( 'submenu' ) ) {
		location.href = 'gpiosettings.php';
		return
	}
	
	GUI.imodedelay = 1; // fix imode flashing on usb dac switching
	if ( GUI.gpio === 'ON' ) {
		if ( GUI.status.state !== 'stop' ) {
			$( '#stop' ).click();
			setTimeout( function() {
				$.get( 'gpioexec.php?command=gpiooff.py'  );
			}, 300 );
		} else {
			$.get( 'gpioexec.php?command=gpiooff.py'  );
		}
	} else {
		$.get( 'gpioexec.php?command=gpioon.py' );
	}
} );

$( '#syscmd-poweroff, #syscmd-reboot' ).off( 'click' ).on( 'click', function() {
	$.get( 'gpioexec.php?command='+ ( this.id == 'syscmd-reboot' ? ' reboot' : 'poweroff' ) );
	toggleLoader();
} );

} ); //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
