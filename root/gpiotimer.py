#!/usr/bin/python
from gpio import *

if timer == 0 or state == OFF:
	exit()
	
i = timer
while i >= 0:
	time.sleep( 60 )
	status = os.system( 'cat /proc/asound/card*/pcm*/sub*/status | grep -q state' ) # state: RUNNING
	if status == 0:
		i = timer
	else:
		i -= 1
		if i == 1: # broadcast last loop
			requests.post( 'http://localhost/pub?id=gpio', json={ 'state': 'IDLE', 'delay': 60 } )
		if i == 0:
			os.system( '/root/gpiooff.py' )
