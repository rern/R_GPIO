$( function() { //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

$( 'select' ).selectric();

var pin = {
	  1: $( '#pin1' ).val()
	, 2: $( '#pin2' ).val()
	, 3: $( '#pin3' ).val()
	, 4: $( '#pin4' ).val()
};
var pname = {
	  1: $( '#name1' ).val()
	, 2: $( '#name2' ).val()
	, 3: $( '#name3' ).val()
	, 4: $( '#name4' ).val()
};
var timer = $( '#timer' ).val();

$( '.close-root' ).click( function() {
	location.href = '/';
} );
$( '#help' ).click( function() {
	$( this ).toggleClass( 'blue' );
	$( '.help-block' ).toggleClass( 'hide' );
} );
$( '#gpioimgtxt, #close-img' ).click( function() {
	if ( $( '#gpiopin, #gpiopin1' ).is( ':visible' ) && $( '#gpiopin' ).is( ':hidden' ) ) $( '#gpiopin, #gpiopin1' ).toggle();
	$( '#gpiopin' ).slideToggle();
	$( '#fliptxt, #close-img' ).toggle();
	$( this ).find( 'i' ).toggleClass('fa-chevron-circle-down fa-chevron-circle-up')
} );
$( '#gpiopin, #gpiopin1' ).click( function() {
	$( '#gpiopin, #gpiopin1' ).toggle();
} );

txtcolorpin();
txtcolordelay();
txtcolor();

$( '.pin' ).on( 'selectric-change', function() { // 'object' by 'class' must add class '.selectpicker' to suppress twice firing events
	var pnew = this.value;
	var n = this.id.slice( -1 ); // get number
	var on = $( '.on, .off' ).find( 'select:has(option[value='+ pin[ n ] +']:selected)' ); // get existing .on, .off that has this pin
	var off = $( '.off' ).find( 'select:has(option[value='+ pin[ n ] +']:selected)' );

	$( '.on, .off' )
		.find( 'select option:nth-child('+ n +')' )
		.after( '<option value='+ pnew +'>'+ pname[ n ] +' - '+ pnew +'</option>' ); // insert new item in option list ...
	on.val( pnew ); // ... select new option list
	off.val( pnew );

	if ( pin[ n ] != 0 ) $( '.on, .off' ).find( '[value='+ pin[ n ] +']' ).remove(); // remove only not 'none'

	pin = { // update new value
		  1: $( '#pin1' ).val()
		, 2: $( '#pin2' ).val()
		, 3: $( '#pin3' ).val()
		, 4: $( '#pin4' ).val()
	};
	txtcolorpin();
} );
$( '.name' ).change( function() {
	var tnew = $( this ).val();
	var n = this.id.slice( -1 );
	var on = $( '.on' ).find( 'select:has(option[value='+ pin[ n ] +']:selected)' ); // get 'select' with existing name
	var off = $( '.off' ).find( 'select:has(option[value='+ pin[ n ] +']:selected)' );
	
	$( '.on, .off' ).find( '[value='+ pin[ n ] +']' ).remove(); // remove existing from option list
	$( '.on, .off' )
		.find( 'select option:nth-child('+ n +')' )
		.after( '<option value='+ pin[ n ] +'>'+ tnew +' - '+ pin[ n ] +'</option>' ); // insert new option to list
	on.val( pin[ n ] ); // select new option
	off.val( pin[ n ] );
	pname = { // update new value
		  1: $( '#name1' ).val()
		, 2: $( '#name2' ).val()
		, 3: $( '#name3' ).val()
		, 4: $( '#name4' ).val()
	};
	txtcolor();
} );
$( '.timer, .delay' ).on( 'selectric-change', function() {
	txtcolor();
} );
$( '.on, .off' ).on( 'selectric-change', function() {
	var on = this.id.slice( 0, 2 ) == 'on'; // get on/off
	var pnew = this.value;
	$( on ? '.on' : '.off' ).each( function() {
		var el = $( this ).find( 'select:has(option[value='+ pnew +']:selected)' ); // find existing selected ...
		if ( el.length ) el.val( 0 ); // ... reset existing selected to 'none'
	});
	$( this ).val( pnew ); // select 'pnew'
	txtcolordelay();
	txtcolor();
} );
$( '#gpiosave' ).click( function() {
	var on = [ 
		  $( '#on1' ).val()
		, $( '#on2' ).val()
		, $( '#on3' ).val()
		, $( '#on4' ).val()
	].filter( function( x ) { return x != 0; } ).length;
	var off = [
		  $( '#off1' ).val()
		, $( '#off2' ).val()
		, $( '#off3' ).val()
		, $( '#off4' ).val()
	].filter( function( x ) { return x != 0; } ).length;
	if ( on !== off ) {
		info( {
			  icon    : 'gpio'
			, title   : 'RuneUI GPIO'
			, message : on +' On : '+ off +' Off \nNumber of equipments not matched !'
		} );
	} else {
		var pinname = {}
		for ( i = 1; i < 5; i++ ) {
			pinname[ $( '#pin'+ i ).val() ] = $( '#name'+ i ).val() || '';
		}
		var on = {}
		for ( i = 1; i < 5; i++ ) {
			on[ 'on'+ i ] = Number( $( '#on'+ i ).val() ) || '';
			if ( i == 4 ) break
			on[ 'ond'+ i ] = Number( $( '#ond'+ i ).val() ) || 0;
		}
		var off = {}
		for ( i = 1; i < 5; i++ ) {
			off[ 'off'+ i ] = Number( $( '#off'+ i ).val() ) || '';
			if ( i == 4 ) break
			off[ 'offd'+ i ] = Number( $( '#offd'+ i ).val() ) || 0;
		}
		var timer = Number( $( '#timer' ).val() )
		var gpiojson = {
			  name : pinname
			, on   : on
			, off  : off
			, timer : timer
		}
		$.post( 'commands.php', { bash: [
			  "echo '"+ JSON.stringify( gpiojson ) +"' | jq > /srv/http/data/system/gpio.json"
			, 'test -e /srv/http/data/tmp/gpiotimer && echo '+ timer +' > /srv/http/data/tmp/gpiotimer'
		] } );
		info( {
			  icon    : 'gpio'
			, title   : 'RuneUI GPIO'
			, message : 'Settings saved.'
		} );
	}
} );

function txtcolorpin() {
	$( '.pin, .on, .off' )
		.find( 'option' )
		.show(); // default show all
	$( '.pin' ) // hide used pin in options
		.find( 'option[value='+ pin[ 1 ] +' ], [value='+ pin[ 2 ] +'], [value='+ pin[ 3 ] +'], [value='+ pin[ 4 ] +']' )
		.hide();
}
function txtcolordelay() {
	$( '.delay' )
		.prop( 'disabled', false ); // default enabled
	$( '.on, .off' ).each( function() { // delay 0 & disabled for 'none' equipment
		var txt = this.id.slice( 0, -1 );
		var num = this.id.slice( -1 ) - 1;
		var sum = 0;
		for ( var i = num; i > 0; i-- ) { // sum previous pins
			var pin = $( '#'+ txt + i ).val();
			sum = sum + pin;
		}
		if ( this.value == 0 || sum == 0 ) { // this 'on/off' = none or all previous = none
			var dly = '#'+ txt +'d'+ num;
			$( dly ).val( 0 ).prop( 'disabled', true );
		}
	} );
	
	$( '.delay' ).selectric( 'refresh' );
}
function txtcolor() {
	$( '.timer, .delay, .on, .off' ).each( function() {
		$this = $( this );
		if ( !$this.prop( 'disabled' ) ) $this.parent().next().find( '.label' ).toggleClass( 'cgl', $this.val() == 0 );
	} );
}

} ); //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
