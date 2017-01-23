$(document).ready(function() {
// document ready start********************************************************************
var timer = false; // for 'setInterval' status check

function buttonOnOff(enable, pullup) {
	if (pullup == 0 || pullup == 'ON') { // R pulldown low > trigger signal = relay on
		$('#gpio').addClass('btn-primary');
		$('#gpio i').removeClass('fa-volume-off').addClass('fa-volume-up');
	} else {
		$('#gpio').removeClass('btn-primary');
		$('#gpio i').removeClass('fa-volume-up').addClass('fa-volume-off');
	}
	if (enable == 1) {
		$('#gpio').show();
	} else {
		$('#gpio').hide();
	}
}
function gpioOnOff() {
	$.get('gpiostatus.php', function(status) {
		var json = $.parseJSON(status);
		buttonOnOff(json.enable, json.pullup);
	});
}
gpioOnOff(); // initial run
document.addEventListener('visibilitychange', function(change) {
	if (document.visibilityState === 'visible') {
		//pushstreamGPIO.connect(); // force reconnect
		gpioOnOff(); // update gpio button on reopen page
	}
});
// nginx pushstream websocket (broadcast)
var pushstreamGPIO = new PushStream({
	host: window.location.hostname,
	port: window.location.port,
	modes: GUI.mode
});
pushstreamGPIO.onmessage = function(state) { // on receive broadcast
	// pushstream message is array
	var sec = parseInt(state[0]);
	var state = state[0].replace(/[0-9]/g, '');
	var txt = {
		'ON': 'Powering ON ...',
		'OFF': 'Powering OFF ...',
		'IDLE': 'IDLE Timer OFF\nin '+ sec +' seconds ...',
		'FAILED': 'Powering FAILED !',
	}
	var dly = {
		'ON': 8000,
		'OFF': 4000,
		'IDLE': sec * 1000,
		'FAILED': 8000,
	}
	if (timer) { // must clear before pnotify can remove
		clearInterval(timer);
		timer = false;
	}
	PNotify.removeAll();
	new PNotify({
		icon: (state != 'FAILED') ? 'fa fa-cog fa-spin fa-lg' : 'fa fa-warning fa-lg',
		title: 'GPIO',
		text: txt[state],
		delay: dly[state],
		addclass: 'pnotify_custom',
		confirm: {
			confirm: state == 'IDLE' ? true : false,
			buttons: [{
				text: 'Timer Reset',
				click: function(notice) {
					$.get('gpiotimerreset.php');
					notice.remove();
				}
			}, null]
		},
		before_open: function() {
			if (state == 'IDLE') {
				timer = setInterval(function() {
					if (sec == 1) clearInterval(timer);
					$('.ui-pnotify-text').html('IDLE Timer OFF<br>in '+ sec-- +' sec ...');
				}, 1000);
			}
		},
		after_close: function() {
			if (state == 'ON' || state == 'OFF') buttonOnOff(1, state);
			if (timer) {
				clearInterval(timer);
				timer = false;
			}
			if (state == 'FAIL') gpioOnOff();
		}
	});
}
pushstreamGPIO.addChannel('gpio');
pushstreamGPIO.connect();

$('#gpio').click(function() {
	var on = $('#gpio').hasClass('btn-primary');
	$.get('gpiostatus.php', function(status) { // disable immediate toggle
		if (status) {
			var json = $.parseJSON(status);
			var delay = 8000 + 1000 * (on ? json.offd : json.ond);
			$('#gpio').prop('disabled', true);
			setTimeout(function() { // re-enable 8s after sequence
				$('#gpio').prop('disabled', false);
			}, delay);
		}
	});
	$.get(on ? 'gpiooff.php' : 'gpioon.php',
		function(state) {
		if (state){
			PNotify.removeAll();
			new PNotify({
				icon: 'fa fa-warning fa-lg',
				title: 'GPIO',
				text: state,
				delay: 4000,
				addclass: 'pnotify_custom'
			});
			gpioOnOff();
		}
		$.get('gpiostatus.php', function(status) {
			var json = $.parseJSON(status);
			if (json.vol == $('#volume-knob').is(':visible')) {
				buttonOnOff(json.enable, json.pullup);
			} else {
				location.reload();
			}
		});
	});
});

// play reset timer
$('#play').click(function(){
	$.get('gpiostatus.php', function(status) {
		var json = $.parseJSON(status);
		if (json.pullup == 0) {
			$.get('gpiotimerreset.php');
			PNotify.removeAll();
		}
	});
});

// power off menu
$('#reboot, #poweroff').click(function() {
	var file = this.id +'.php';
	$.get('gpiostatus.php', function(status) {
		var json = $.parseJSON(status);
		if (json.pullup) {
			$.get(file);
		} else {
			$.get('gpiooff.php', function() {
				$.get(file);
			});
		}
	});
});
// document ready end *********************************************************************
});