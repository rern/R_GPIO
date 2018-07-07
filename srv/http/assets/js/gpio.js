$( function() { //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

var timer = false; // for 'setInterval' status check

function gpioOnOff() {
	$.get( '/gpioexec.php?onoffpy=gpio.py state', function( state ) {
		gpioon = state === 'ON' ? 1 : 0;
		$( '#gpio' ).css( 'background', gpioon ? '#0095d8' : '#34495e' );
	} );
}

gpioOnOff();
if ( !timer ) $( '#infoX' ).click();

document.addEventListener( 'visibilitychange', function( change ) {
	if ( document.visibilityState === 'visible' ) {
		gpioOnOff(); // update gpio button on reopen page
		PNotify.removeAll();
		if ( !timer ) $( '#infoX' ).click();
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
			  icon        : 'cog fa-spin'
			, title       : 'GPIO Timer'
			, message     : 'Idel Off Countdown:<br><white>'+ delay +'</white> s ...'
			, cancellabel : 'Hide'
			, cancel      : 1
			, oklabel     : 'Reset'
			, ok          : function() {
				$.get( '/gpioexec.php?onoffpy=gpiotimer.py' );
			}
		} );
		timer = setInterval( function() {
			if ( delay == 1 ) {
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
			if ( state != 'FAILED !' ) {
				$( '#gpio i' ).css( 'color', state == 'ON' ? '#0095d8' : '#e0e7ee' );
			} else {
				gpioOnOff();
			}
		}, delay * 1000 );
	}
	if ( state == 'OFF' ) $( '#infoX' ).click();
};
pushstreamGPIO.connect();

var $hammergpio = new Hammer( document.getElementById( 'gpio' ) );

$hammergpio.on( 'tap',  function( e ) {
	var on = gpioon ? 'ON' : 'OFF';
	$( '#settings' ).hide();
/*	$( this ).prop( 'disabled', true );
	setTimeout( function() {
		$( '#gpio' ).prop( 'disabled', false ); // $(this) not work
	}, 10000 );*/
	
	var py = ( on == 'ON' ) ? 'gpiooff.py' : 'gpioon.py';
	$.get( '/gpioexec.php?onoffpy='+ py,
		function( state ) {
			if ( state.state == on ) {
				PNotify.removeAll();
				new PNotify( {
					  icon : 'fa fa-warning fa-lg'
					, title: 'GPIO'
					, text : on ? 'Already ON' : 'Already OFF'
					, delay: 4000
					, addclass: 'pnotify_custom'
				} );
				gpioOnOff();
			}
		}
	);
} ).on( 'press', function() {
	window.location.href = 'gpiosettings.php';
} );

// power off menu
$( '#syscmd-poweroff, #syscmd-reboot' ).off( 'click' ).on( 'click', function() {
	reboot = ( this.id == 'syscmd-reboot' ) ? ' reboot' : '';
	$.get( '/gpioexec.php?onoffpy=gpiopower.py'+ reboot );
});

// force href open in web app window (from: https://gist.github.com/kylebarrow/1042026)
if ( ( 'standalone' in window.navigator ) && window.navigator.standalone ) {
	// If you want to prevent remote links in standalone web apps opening Mobile Safari, change 'remotes' to true
	var noddy, remotes = true;
	
	document.addEventListener( 'click', function( event ) {
		noddy = event.target;
		// Bubble up until we hit link or top HTML element. Warning: BODY element is not compulsory so better to stop on HTML
		while ( noddy.nodeName !== 'A' && noddy.nodeName !== 'HTML' ) {
	        noddy = noddy.parentNode;
	    }
		if ( 'href' in noddy && noddy.href.indexOf( 'http' ) !== -1 && ( noddy.href.indexOf( document.location.host ) !== -1 || remotes ) ) {
			event.preventDefault();
			document.location.href = noddy.href;
		}
	}, false );
}

} ); //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
