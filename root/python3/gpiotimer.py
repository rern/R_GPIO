#!/usr/bin/python
from gpio import *

if timer == 0 or state == OFF:
	exit()
	
i = timer
while i >= 0:
	time.sleep( 60 )
	if os.system( 'cat /proc/asound/card*/pcm*/sub*/status | grep -q state' ) == 0: # state: RUNNING
		i = timer
	else:
		i -= 1
		if i == 1: # broadcast last loop
			data = ( state='IDLE', delay=60 )
			requestData( d )
			
		if i == 0:
			if os.system( 'cat /proc/asound/card*/pcm*/sub*/status | grep -q state' ) != 0: # all 'closed' - no 'state'
				os.system( '/root/gpiooff.py' )
			else:
				i = timer
