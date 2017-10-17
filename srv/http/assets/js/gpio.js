$( document ).ready( function() {
// document ready start********************************************************************
var timer = false; // for 'setInterval' status check
ond = $( '#ond' ).val() * 1000;
offd = $( '#offd' ).val() * 1000;

function buttonOnOff( enable, pullup ) {
	if ( pullup == 0 || pullup == 'ON' ) { // R pulldown low > trigger signal = relay on
		$( '#gpio' ).addClass( 'btn-primary' );
		$( '#gpio i' ).removeClass( 'fa-volume-off' ).addClass( 'fa-volume-up' );
	} else {
		$( '#gpio' ).removeClass( 'btn-primary' );
		$( '#gpio i' ).removeClass( 'fa-volume-up' ).addClass( 'fa-volume-off' );
	}
	if ( enable == 1 ) {
		$( '#gpio' ).show();
	} else {
		$( '#gpio' ).hide();
	}
}
(function gpioOnOff() {
	var path = /\/.*\//.test( window.location.pathname ) ? '../../' : '';
	$.get( path +'gpioexec.php?gpio=gpio.py status', function( status ) {
		var json = $.parseJSON( status );
		buttonOnOff( json.enable, json.pullup );
	} );
})();

document.addEventListener( 'visibilitychange', function( change ) {
	if ( document.visibilityState === 'visible' ) {
		//pushstreamGPIO.connect(); // force reconnect
		gpioOnOff(); // update gpio button on reopen page
	}
} );
// nginx pushstream websocket (broadcast)
var pushstreamGPIO = new PushStream( {
	host: window.location.hostname,
	port: window.location.port,
	modes: GUI.mode
} );
pushstreamGPIO.onmessage = function( response ) { // on receive broadcast
	// pushstream message is array
	var sec = parseInt( response[ 0 ] );
	var state = response[ 0 ].replace( /[0-9]/g, '' );
	var txt = {
		  ON    : 'Powering ON ...'
		, OFF   : 'Powering OFF ...'
		, IDLE  : 'IDLE Timer OFF\nin '+ sec +' seconds ...'
		, FAILED: 'Powering FAILED !'
	};
	var dly = {
		  ON    : ond
		, OFF   : offd
		, IDLE  : sec * 1000
		, FAILED: 8000
	};
	if ( timer ) { // must clear before pnotify can remove
		clearInterval( timer );
		timer = false;
	}
	PNotify.removeAll();
	new PNotify( {
		  icon    : ( state != 'FAILED' ) ? 'fa fa-cog fa-spin fa-lg' : 'fa fa-warning fa-lg'
		, title   : 'GPIO'
		, text    : txt[ state ]
		, delay   : dly[ state ]
		, addclass: 'pnotify_custom'
		, confirm: {
			  confirm: state == 'IDLE' ? true : false
			, buttons: [ {
				  text : 'Timer Reset'
				, click: function( notice ) {
					$.get( 'gpiotimerreset.php' );
					notice.remove();
				}
			}, null ]
		}
		, before_open: function() {
			if ( state == 'IDLE' ) {
				timer = setInterval( function() {
					if ( sec == 1 ) clearInterval( timer );
					$( '.ui-pnotify-text' ).html( 'IDLE Timer OFF<br>in '+ sec-- +' sec ...' );
				}, 1000 );
			}
		}
		, after_close: function() {
			if ( state == 'ON' || state == 'OFF' ) buttonOnOff( 1, state );
			if ( timer ) {
				clearInterval( timer );
				timer = false;
			}
			if ( state == 'FAIL' ) gpioOnOff();
		}
	} );
};
pushstreamGPIO.addChannel( 'gpio' );
pushstreamGPIO.connect();

$( '#gpio' ).click( function() {
	var on = $( this ).hasClass( 'btn-primary' );
	$( this ).prop( 'disabled', true );
	setTimeout( function() {
		$( '#gpio' ).prop( 'disabled', false ); // $(this) not work
	}, on ? offd : ond );
	
	path = /\/.*\//.test( window.location.pathname ) ? '../../' : '';
	var file = on ? 'gpiooff.py' : 'gpioon.py';
	$.get( path +'gpioexec.php?gpio='+ file,
		function( status ) {
			var json = $.parseJSON( status );
			if ( json.pullup == on ? 1 : 0 ) {
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
			if ( json.conf == 1 ) location.reload();
		}
	);
} );

// gpiosettings menu
$( '#gpiosettings' ).click( function() {
	path = /\/.*\//.test( window.location.pathname ) ? '../../' : '';
	window.location.href = path +'gpiosettings.php';
});
	
// power off menu
$( '#reboot, #poweroff' ).click( function() {
	path = /\/.*\//.test( window.location.pathname ) ? '../../' : '';
	$.get( path +'gpioexec.php?gpio='+ this.id +'.py' );
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

// document ready end *********************************************************************
} );
