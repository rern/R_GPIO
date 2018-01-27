$( document ).ready( function() {

var enable = $( '#gpio-enable' ).val();
var pin = {
	  1: $( '#pin1' ).val()
	, 2: $( '#pin2' ).val()
	, 3: $( '#pin3' ).val()
	, 4: $( '#pin4' ).val()
};
var name = {
	  1: $( '#name1' ).val()
	, 2: $( '#name2' ).val()
	, 3: $( '#name3' ).val()
	, 4: $( '#name4' ).val()
};
var timer = $( '#timer' ).val();

$( '#close' ).click( function() {
	window.location.href = '/';
} );
$( '#gpioimgtxt' ).click( function() {
	$( this ).parent().next().slideToggle();
	$( this ).find( 'i' ).toggleClass('fa-caret-down fa-caret-up')
} );
$( '#gpio-enable' ).click( function() {
	if ( this.value == 1 ) {
		$( this ).val( 0 );
		if ( enable == 0 ) $( '#audiolabel, #audioout, #gpio-group' ).hide();
	} else {
		$( this ).val( 1 );
		$( '#audiolabel, #audioout, #gpio-group' ).show();
	}
} );
$( '#aogpio' ).on( 'changed.bs.select', function() {
	window.location.href = '/mpd/';
} );

function txtcolorpin() {
	$( '.pin, .on, .off' )
		.selectpicker( 'render' ) // must 'render' after 'value' changed
		.find( 'option' )
		.show(); // default show all
	$( '.pin' ) // hide used pin in options
		.find( 'option[value='+ pin[ 1 ] +' ], [value='+ pin[ 2 ] +'], [value='+ pin[ 3 ] +'], [value='+ pin[ 4 ] +']')
		.hide();
	$( '.pin, .on, .off' ).selectpicker( 'refresh' ); // must 'refresh' after 'css' changed
}
function txtcolorname() {
	$( '.name, .on, .off' )
		.selectpicker( 'render' )
		.css( 'color', '#e0e7ee' ) // default color text
		.filter( function() { // .find('input[value="(no name)"]') not work
			return this.value == '(no name)';
		})
		.css( 'color', '#587ca0' ); // '(no name)' gray text
	$( '.name, .on, .off' ).selectpicker( 'refresh' );
}
function txtcolordelay() {
	$( '.delay' )
		.selectpicker( 'render' )
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
	// 'render' & 'refresh' in textcolor()
}
function txtcolor() {
	$( '.timer, .delay, .on, .off' )
		.find( 'span:contains("none"), option[value=0]' )
		.css( 'color', '#587ca0' ); // 'none' gray text
	$( '.timer, .delay, .on, .off' ).selectpicker( 'refresh' );
}

txtcolorpin();
txtcolorname();
txtcolordelay();
txtcolor();

$( '.selectpicker' ).selectpicker( {
	  iconBase: 'fontawesome'
	, tickIcon: 'fa fa-check'
} );
$( '.selectpicker.pin' ).change( function() { // 'object' by 'class' must add class '.selectpicker' to suppress twice firing events
	var pnew = this.value;
	var n = this.id.slice( -1 ); // get number
	var on = $( '.on, .off' ).find( 'select:has(option[value='+ pin[ n ] +']:selected)' ); // get existing .on, .off that has this pin
	var off = $( '.off' ).find( 'select:has(option[value='+ pin[ n ] +']:selected)' );

	$( '.on, .off' )
		.find( 'select option:nth-child('+ n +')' )
		.after( '<option value='+ pnew +'>'+ name[ n ] +' - '+ pnew +'</option>' ); // insert new item in option list ...
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
$( '.name' ).click( function() {
	if ( $( this ).val() == '(no name)' ) $( this ).val( '' );
} ).blur( function() {
	if ( !$( this ).val() ) $( this ).val( '(no name)' );
} ).change( function() {
	var tnew = '';
	if ( this.value != '' && this.value != '(no name)' ) {
		tnew = $( this ).val();
	} else {
		tnew = '(no name)';
		$( this ).val( tnew );
	}
	var n = this.id.slice( -1 );
	var on = $( '.on' ).find( 'select:has(option[value='+ pin[ n ] +']:selected)' ); // get 'select' with existing name
	var off = $( '.off' ).find( 'select:has(option[value='+ pin[ n ] +']:selected)' );
	
	$( '.on, .off' ).find( '[value='+ pin[ n ] +']' ).remove(); // remove existing from option list
	$( '.on, .off' )
		.find( 'select option:nth-child('+ n +')' )
		.after( '<option value='+ pin[ n ] +'>'+ tnew +' - '+ pin[ n ] +'</option>' ); // insert new option to list
	on.val( pin[ n ] ); // select new option
	off.val( pin[ n ] );
	name = { // update new value
		  1: $( '#name1' ).val()
		, 2: $( '#name2' ).val()
		, 3: $( '#name3' ).val()
		, 4: $( '#name4' ).val()
	};
	txtcolorname();
} );
$( '.selectpicker.timer, .selectpicker.delay' ).change( function() {
	txtcolor();
} );
$( '.selectpicker.on, .selectpicker.off' ).change( function() {
	var on = this.id.slice( 0, 2 ) == 'on'; // get on/off
	var pnew = this.value;
	$( on ? '.on' : '.off' ).each( function() {
		var el = $( this ).find( 'select:has(option[value='+ pnew +']:selected)' ); // find existing selected ...
		if ( el.length ) el.val( 0 ); // ... reset existing selected to 'none'
	});
	$( this ).val( pnew ); // select 'pnew'
//	$(on ? '.ond' : '.offd').val(0);
	txtcolordelay();
	txtcolor();
} );

$( '#gpiosave' ).click( function() {
	enable = $( '#gpio-enable' ).val();
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
		alert( on +' On : '+ off +' Off \nNumber of equipments not matched !' );
	} else {
		$( '.delay' ).prop( 'disabled', false ); // for serialize
		$.post( 'gpiosave.php',
			$( '#gpioform').serialize() +'&enable='+ enable,
			function( data ) {
				if ( data ) {
					var icon = 'fa fa-info-circle fa-lg';
					var result = 'Settings saved'; 
					$.get( 'gpiotimerreset.php' );
					if ( enable == 0 ) $( '#audiolabel, #audioout, #gpio-group' ).hide();
				} else {
					var icon = 'fa fa-warning fa-lg';
					var result = 'Settings FAILED!';
				}
				new PNotify( {
					  icon    : icon
					, title   : 'GPIO'
					, text    : result
					, delay   : 3000
					, addclass: 'pnotify_custom'
				} );
			}
		);
	}
} );

} );
