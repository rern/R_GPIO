#!/usr/bin/python
import gpiooff
import sys
import os

if len( sys.argv ) == 1:
	os.system( '/var/www/command/rune_shutdown' )
	exit()
	
if sys.argv[ 1 ] != 'reboot':
	os.system( '/usr/bin/sudo /bin/echo '+ sys.argv[ 1 ] +' > /sys/module/bcm2709/parameters/reboot_part' )
	
os.system( '/var/www/command/rune_shutdown; reboot' )
