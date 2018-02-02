#!/usr/bin/python
from gpio import *
import mpd

if timer == 0 or pullup == OFF:
	exit()
	
i = timer
while i >= 0:
	time.sleep( 60 )
	client = mpd.MPDClient( use_unicode=True )
	client.connect( 'localhost', 6600 )
	state = client.status()[ 'state' ]
	status = os.system( 'cat /proc/asound/card*/pcm*/sub*/status | grep -q state' ) # airplay
	client.close()
	client.disconnect()
	if state == 'play' or status == 0:
		i = timer
	else:
		i -= 1
		if i == 1: # broadcast last loop
			requests.post( 'http://localhost/pub?id=gpio', json={ 'state': 'IDLE', 'delay': 60 } )
		if i == 0:
			os.system( '/root/gpiooff.py' )
