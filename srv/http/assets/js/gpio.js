$( function() { //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

var stopwatch = '<span id="stopwatch" class="fa-stack fa-2x">'
				+'<i class="fa fa-stopwatch-i fa-spin fa-stack-1x"></i>'
				+'<i class="fa fa-stopwatch-o fa-stack-1x"></i>'
				+'</span>'
var timer = false; // for 'setInterval' status check

function gpioOnOff() {
	$.get( '/gpioexec.php?command=gpio.py state', function( state ) {
		$( '#gpio' ).toggleClass( 'gpioon', state === 'ON' );
		$( '#igpio' ).toggleClass( 'hide', state === 'OFF' );
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
			  icon        : stopwatch
			, title       : 'GPIO Timer'
			, message     : 'Idel Off Countdown:<br>'+ stopwatch +'&emsp;<white>'+ delay +'</white> s ...'
			, cancellabel : 'Hide'
			, cancel      : 1
			, oklabel     : 'Reset'
			, ok          : function() {
				$.get( '/gpioexec.php?command=timer' );
			}
		} );
		timer = setInterval( function() {
			if ( delay == 1 ) {
				imodedelay = 1;
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
				$( '#gpio' ).toggleClass( 'gpioon', state == 'ON' );
				$( '#igpio' ).toggleClass( 'hide', state === 'OFF' );
				//$( '#imode' ).show();
			}
		}, delay * 1000 );
		
		setTimeout( function() {
			clickdelay = 0;
		}, ( delay + 10 ) * 1000 );
		setTimeout( function() {
			imodedelay = 0;
		}, 5000 );
	}
	if ( state == 'OFF' ) $( '#infoX' ).click();
};
pushstreamGPIO.connect();

var clickdelay = 0;
var $hammergpio = new Hammer( document.getElementById( 'gpio' ) );
$hammergpio.on( 'press', function() {
	window.location.href = 'gpiosettings.php';
} ).on( 'tap',  function() {
	// prevent instant on/off
	if ( clickdelay ) {
		info( {
			  icon    : 'info-circle'
			, message :'Please wait 10 seconds between on / off'
		} );
		return;
	}
	clickdelay = 1;
	imodedelay = 1; // fix imode flashing on usb dac switching

	$( '#settings' ).hide();
	$.get( '/gpioexec.php?command='+ ( $( '#gpio' ).hasClass( 'gpioon' ) ? 'gpiooff.py' : 'gpioon.py' ) );
} );

if ( $( '#turnoff' ).length ) {
	$( '#turnoff' ).off( 'click' ).on( 'click', function() {
		info( {
			  icon        : 'power-off'
			, title       : 'Power'
			, message     : 'Select mode:'
			, oklabel     : 'Power off'
			, okcolor     : '#bb2828'
			, ok          : function() {
				$.get( '/gpioexec.php?command=poweroff' );
				toggleLoader();
			}
			, buttonlabel : 'Reboot'
			, buttoncolor : '#9a9229'
			, button      : function() {
				$.get( '/gpioexec.php?command=reboot' );
				toggleLoader();
			}
		} );
	} );
} else {
	// default power off menu
	$( '#syscmd-poweroff, #syscmd-reboot' ).off( 'click' ).on( 'click', function() {
		$.get( '/gpioexec.php?command='+ ( this.id == 'syscmd-reboot' ? ' reboot' : 'poweroff' ) );
		toggleLoader();
	});
}

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
