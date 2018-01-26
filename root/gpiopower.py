#!/usr/bin/python
import gpiooff
import sys
import os

if len( sys.argv ) == 1:
	os.system( '/var/www/command/rune_shutdown' )
	exit()

arg = sys.argv[ 1 ]
if arg != 'reboot':
	kernel = os.system( '/usr/bin/uname -r | cut -d"-" -f1' )
	if kernel > '4.4.39':
		os.system( '/var/www/command/rune_shutdown; reboot ' arg )
		exit()
	else:
		os.system( '/bin/echo '+ arg +' > /sys/module/bcm2709/parameters/reboot_part' )
		
os.system( '/var/www/command/rune_shutdown; reboot' )
