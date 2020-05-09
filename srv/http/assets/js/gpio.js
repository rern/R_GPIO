var stopwatch = '<span class="stopwatch">'
				+'<i class="fa fa-stopwatch-i fa-spin"></i>'
				+'<i class="fa fa-stopwatch-o"></i>'
				+'</span>';
var timer = false; // for 'setInterval' status check
G.icondelay = 0;

$( '#gpio' ).click( function( e ) {
	if ( $( e.target ).hasClass( 'submenu' ) ) {
		location.href = 'gpiosettings.php';
	} else {
		//G.icondelay = 1; // fix imode flashing on usb dac switching
		$.post( 'commands.php', { bash: '/usr/local/bin/gpio'+ ( G.gpio ? 'off' : 'on' ) +'.py' } );
		$( '#settings' ).addClass( 'hide' );
	}
} );

onVisibilityChange( function( visible ) {
	if ( visible ) gpioOnOff();
} );
function gpioCountdown( i, iL, delays, state ) {
	setTimeout( function() {
		$( '#device'+ i ).toggleClass( 'gr' );
		i++;
		i < iL ? gpioCountdown( i, iL, delays, state ) : setTimeout( infoReset, 1000 );
	}, delays[ i ] * 1000 );
	
}
function gpioOnOff() {
	$.post( 'commands.php', { bash0: '[[ -e /srv/http/data/tmp/gpioon ]] && echo true || echo false' }, function( state ) {
		G.gpio = state;
	}, 'json' );
}
gpioOnOff();
function psGPIO( response ) { // on receive broadcast
	var state = response.state;
	G.gpio = state;
	var delay = response.delay;
	if ( timer ) { // must clear before pnotify can remove
		clearInterval( timer );
		timer = false;
	}
	if ( state === 'RESET' ) {
		$( '#infoX' ).click();
	} else if ( state === 'IDLE' ) {
		info( {
			  icon        : 'gpio'
			, title       : 'GPIO Idle Timer'
			, message     : 'Power Off Countdown:<br><br>'
						   + stopwatch +'<white>'+ delay +'</white>'
			, oklabel     : 'Reset'
			, ok          : function() {
				$.post( 'commands.php', { bash: [
					  'pkill gpiotimer.py &> /dev/null'
					, '/usr/local/bin/gpiotimer.py &> /dev/null &'
					, 'curl -s -X POST "http://127.0.0.1/pub?id=gpio" -d \'{ "state": "RESET" }\''
				] } );
			}
		} );
		timer = setInterval( function() {
			if ( delay === 1 ) {
				G.gpio = false;
				setButtonToggle();
				G.icondelay = 1;
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
			, title     : 'GPIO'
			, message   : stopwatch +' <wh>Power '+ state +'</wh><hr>'
						+ devices
			, nobutton  : 1
		} );
		var iL = delays.length;
		var i = 0
		gpioCountdown( i, iL, delays, state );
		setTimeout( function() {
			setButtonToggle();
		}, delay * 1000 );
		setTimeout( function() {
			G.icondelay = 0;
		}, 5000 );
	}
}
