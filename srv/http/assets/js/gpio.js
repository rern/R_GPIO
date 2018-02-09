$( document ).ready( function() {
// document ready start********************************************************************
var timer = false; // for 'setInterval' status check

function buttonOnOff( pullup ) {
	if ( pullup == 1 || pullup == 'ON' ) { // R pullup = 3.3V > high trigger > relay ON
		$( '#gpio' ).addClass( 'btn-primary' );
		$( '#gpio i' ).removeClass( 'fa-volume-off' ).addClass( 'fa-volume-up' );
	} else {
		$( '#gpio' ).removeClass( 'btn-primary' );
		$( '#gpio i' ).removeClass( 'fa-volume-up' ).addClass( 'fa-volume-off' );
	}
	if ( $( '#enable' ).val() == 1 ) {
		$( '#gpio' ).show();
	} else {
		$( '#gpio' ).hide();
	}
}
function gpioOnOff() {
	$.get( '/gpioexec.php?onoffpy=gpio.py status', function( status ) {
		var json = $.parseJSON( status );
		buttonOnOff( json.pullup );
	} );
}
gpioOnOff();

document.addEventListener( 'visibilitychange', function( change ) {
	if ( document.visibilityState === 'visible' ) {
		//pushstreamGPIO.connect(); // force reconnect
		gpioOnOff(); // update gpio button on reopen page
		if ( timer ) $( '#infoMessage' ).hide();
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
	if ( state == 'IDLE' ) {
		info( {
			  icon        : '<i class="fa fa-cog fa-spin fa-2x"></i>'
			, title       : 'GPIO Timer'
			, message     : 'IDLE Timer OFF<br>in <white>'+ delay +'</white> sec ...'
			, cancellabel : 'Hide'
			, cancel      : 1
			, oklabel     : 'Reset'
			, ok          : function() {
				$.get( '/gpioexec.php?onoffpy=timerreset' );
			}
		} );
		timer = setInterval( function() {
			if ( delay == 1 ) {
				$( '#infoOverlay' ).hide();
				clearInterval( timer );
			}
			$( '#infoMessage white' ).text( delay-- );
		}, 1000 );
		return
	} else {
		PNotify.removeAll();
		new PNotify( {
			  icon    : ( state != 'FAILED !' ) ? 'fa fa-cog fa-spin fa-lg' : 'fa fa-warning fa-lg'
			, title   : 'GPIO'
			, text    : 'Powering '+ state
			, delay   : delay * 1000
			, addclass: 'pnotify_custom'
		} );
		setTimeout( function() {  // no 'after_close' in this version of pnotify
			if ( state != 'FAILED !' ) {
				buttonOnOff( state );
			} else {
				gpioOnOff();
			}
		}, delay * 1000 );
	}
	if ( state == 'OFF' ) $( '#infoX' ).click();
};
pushstreamGPIO.connect();

$( '#gpio' ).click( function() {
	var on = $( this ).hasClass( 'btn-primary' );
	$( this ).prop( 'disabled', true );
	setTimeout( function() {
		$( '#gpio' ).prop( 'disabled', false ); // $(this) not work
	}, 10000 );
	
	var py = on ? 'gpiooff.py' : 'gpioon.py';
	$.get( '/gpioexec.php?onoffpy='+ py,
		function( status ) {
			//var json = $.parseJSON( status );
			if ( status.pullup == on ? 1 : 0 ) {
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
} );

// power off menu
$( '#reboot, #poweroff' ).click( function() {
	py = ( this.id == 'reboot' ) ? 'gpiopower.py reboot' : 'gpiopower.py';
	$.get( '/gpioexec.php?gpio='+ py );
});

// force href open in web app window (from: https://gist.github.com/kylebarrow/1042026)
if ( ( "standalone" in window.navigator ) && window.navigator.standalone ) {
	// If you want to prevent remote links in standalone web apps opening Mobile Safari, change 'remotes' to true
	var noddy, remotes = true;
	
	document.addEventListener( 'click', function( event ) {
		noddy = event.target;
		// Bubble up until we hit link or top HTML element. Warning: BODY element is not compulsory so better to stop on HTML
		while ( noddy.nodeName !== "A" && noddy.nodeName !== "HTML" ) {
	        noddy = noddy.parentNode;
	    }
		if ( 'href' in noddy && noddy.href.indexOf( 'http' ) !== -1 && ( noddy.href.indexOf( document.location.host ) !== -1 || remotes ) ) {
			event.preventDefault();
			document.location.href = noddy.href;
		}
	}, false );
}

$( "#dacsave" ).click( function() {
	$.get( "/gpiosave.php?ao=1", function() {
		info( {
			  icon   : '<i class=\"fa fa-info-circle fa-2x\"></i>'
			, title  : 'RuneUI GPIO'
			, message: "MPD configuration saved."
		} );
	} );
} );

// document ready end *********************************************************************
} );
