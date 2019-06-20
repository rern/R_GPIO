var currentlyrics = '';
var lyrics = '';
lyricsArtist = '';
lyricsSong = '';

$( function() { //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

if ( !$( '#swipebar' ).length ) $( '#lyricsedit' ).removeClass().addClass( 'fa fa-edit');
$( '#song, #currentsong' ).click( function() {
	if ( GUI.status ) {
		var playlistlength = GUI.status.playlistlength;
		var artist = GUI.status.Artist;
		var title = GUI.status.Title;
		var file = GUI.status.file;
	} else { // defAULT rUNEui
		var playlistlength = GUI.json.playlistlength;
		var artist = GUI.json.currentartist;
		var title = GUI.json.currentsong;
		var file = GUI.json.file;
	}
	if ( playlistlength == 0 ) return;
	
	
	if ( artist === lyricsArtist && title === lyricsSong && lyrics ) {
		lyricsshow();
		return
	}
	
	if ( file.slice( 0, 4 ) === 'http' ) {
		var title = title.split( / - (.*)/ );
		info( {
			  icon       : 'info-circle'
			, title      : 'Lyrics'
			, width      : 500
			, message    : 'Query with Webradio data as:'
			, textlabel  : [ 'Artist', 'Title' ]
			, textvalue  : [ title[ 0 ], title[ 1 ] ]
			, textalign  : 'center'
			, boxwidth   : 'max'
			, ok         : function() {
				lyricsArtist = $( '#infoTextBox' ).val().trim().replace( /"/g, '\\"' );
				lyricsSong = $( '#infoTextBox2' ).val().trim().replace( /"/g, '\\"' );
				getlyrics();
			}
		} );
	} else {
		lyricsArtist = artist;
		lyricsSong = title;
		getlyrics();
	}
} );
// fix cursor placement issue caused by Pnotify
$( '#lyricstextarea' ).on( 'touchstart', function( e ) {
	e.stopPropagation();
} ).on( 'click', function() {
	$( '#lyricsback, #lyricsundo, #lyricssave' ).toggle();
} );
$( '#lyricsedit' ).click( function() {
	var lyricstop = $( '#lyricstext' ).scrollTop();
	if ( !currentlyrics ) currentlyrics = lyrics;
	$( '#lyricseditbtngroup' ).show();
	$( '#lyricstextareaoverlay' ).removeClass( 'hide' );
	$( '#lyricsedit, #lyricstextoverlay' ).hide();
	if ( lyrics !== '(Lyrics not available.)' ) {
		$( '#lyricstextarea' ).val( currentlyrics ).scrollTop( lyricstop );
	} else {
		$( '#lyricstextarea' ).val( '' );
	}
} );
$( '#lyricsclose' ).click( function() {
	if ( $( '#lyricstextareaoverlay' ).hasClass( 'hide' )
		|| $( '#lyricstextarea' ).val() === currentlyrics
		|| $( '#lyricstextarea' ).val() === ''
	) {
		lyricshide();
	} else {
		info( {
			  title    : 'Lyrics'
			, message  : 'Discard changes made to this lyrics?'
			, ok       : lyricshide
		} );
	}
} );
$( '#lyricsback' ).click( function() {
	$( '#lyricseditbtngroup' ).hide();
	$( '#lyricstextareaoverlay' ).addClass( 'hide' );
	$( '#lyricsedit, #lyricstextoverlay' ).show();
} );
$( '#lyricsundo' ).click( function() {
	$( '#lyricsback, #lyricsundo, #lyricssave' ).toggle();
	lyricstop = $( '#lyricstextarea' ).scrollTop();
	if ( $( '#lyricstextarea' ).val() === currentlyrics
		|| $( '#lyricstextarea' ).val() === ''
	) {
		lyricsrestore( lyricstop );
		return
	}
	info( {
		  title    : 'Lyrics'
		, message  : 'Discard changes made to this lyrics?'
		, ok       : lyricsrestore( lyricstop )
	} );
} );
$( '#lyricssave' ).click( function() {
	if ( $( '#lyricstextarea' ).val() === currentlyrics ) return;
	
	info( {
		  title    : 'Lyrics'
		, message  : 'Save this lyrics?'
		, ok       : function() {
			var newlyrics = $( '#lyricstextarea' ).val();
			$.post( 'lyricssave.php',
				{ artist: $( '#lyricsartist' ).text(), song: $( '#lyricssong' ).text(), lyrics: newlyrics },
				function( data ) {
					if ( data ) {
						lyricstop = $( '#lyricstextarea' ).scrollTop();
						currentlyrics = newlyrics;
						lyrics2html( newlyrics );
						if ( $( '#lyricssong' ).text() == GUI.status ? GUI.status.Title : GUI.json.currentsong ) {
							lyrics = newlyrics;
						}
						$( '#lyricstext, #lyric-text-overlay' ).html( lyricshtml );
						lyricsrestore( lyricstop );
					} else {
						info( {
							  icon    : 'info-circle'
							, title   : 'Lyrics'
							, message : 'Lyrics save failed.'
						} );
					}
				}
			);
		}
	} );
} );	
$( '#lyricsdelete' ).click( function() {
	info( {
		  title    : 'Lyrics'
		, message  : 'Delete this lyrics?'
		, ok       : function() {
			$.post( 'lyricssave.php',
				{ artist: $( '#lyricsartist' ).text(), song: $( '#lyricssong' ).text(), delete: 1 },
				function( data ) {
					if ( data ) {
						currentlyrics = '(Lyrics not available.)';
						lyrics2html( currentlyrics )
						lyricshide();
						$( '#lyric-text-overlay' ).html( lyrics2html );
					}
					info( {
						  icon    : 'info-circle'
						, title   : 'Lyrics'
						, message : data ? 'Lyrics deleted successfully.' : 'Lyrics delete failed.'
					} );
				}
			);
		}
	} );
} );
$( '#menu-bottom' ).click( function() {
	if ( !$( '#lyricscontainer' ).hasClass( 'hide' ) ) lyricshide();
} );

} ); //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

var banner = typeof notify !== 'undefined';
getlyrics = function() {
	if ( banner ) {
		notify( 'Lyrics', 'Fetching ...', 'refresh fa-spin', 20000 );
	} else {
		PNotify.removeAll();
		new PNotify( {
			  icon     : 'fa fa-refresh fa-spin fa-lg'
			, title    : 'Lyrics'
			, text     : 'Fetching ...'
			, hide     : false
			, addclass : 'pnotify_custom'
		} );	}
	$.get( 'lyrics.php',   
		{ artist: lyricsArtist, song: lyricsSong },
		function( data ) {
			lyrics = data ? data : '(Lyrics not available.)';
			lyrics2html( lyrics );
			lyricsshow();
		}
	);
}
lyrics2html = function( data ) {
	lyricshtml = data.replace( /\n/g, '<br>' ) +'<br><br><br>·&emsp;·&emsp;·';
}
lyricsshow = function() {
	$( '#lyricssong' ).text( lyricsSong );
	$( '#lyricsartist' ).text( lyricsArtist );
	$( '#lyricstext, #lyric-text-overlay' ).html( lyricshtml );
	var bars = GUI.status ? GUI.bars : !$( '#menu-top' ).hasClass( 'hide' );
	$( '#lyricscontainer' )
		.css( {
			  top    : ( bars ? '' : 0 )
			, height : ( bars ? '' : '100vh' )
		} )
		.removeClass( 'hide' );
	$( '#lyricstext' ).scrollTop( 0 );
	if ( bars ) $( '#menu-bottom' ).addClass( 'lyrics-menu-bottom' );
	if ( banner ) {
		bannerHide();
	} else {
		PNotify.removeAll();
	}
}
lyricshide = function() {
	currentlyrics = '';
	lyrics2html( lyrics );
	$( '#lyricstextarea' ).val( '' );
	$( '#lyricsedit, #lyricstextoverlay' ).show();
	$( '#lyricseditbtngroup' ).hide();
	$( '#lyricscontainer, #lyricstextareaoverlay' ).addClass( 'hide' );
	if ( GUI.bars || !$( '#menu-top' ).hasClass( 'hide' ) ) $( '#menu-bottom' ).removeClass( 'lyrics-menu-bottom' );
}
lyricsrestore = function( lyricstop ) {
	$( '#lyricseditbtngroup' ).hide();
	$( '#lyricstextareaoverlay' ).addClass( 'hide' );
	$( '#lyricsedit, #lyricstextoverlay' ).show();
	$( '#lyricstext' ).scrollTop( lyricstop );
}
