#!/usr/bin/python
import sys
import os

if len(sys.argv) > 1:
	part=sys.argv[1]
	os.system('/usr/bin/sudo /bin/echo' part '> /sys/module/bcm2709/parameters/reboot_part')
os.system('/var/www/command/rune_shutdown; reboot')
