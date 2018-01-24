#!/usr/bin/python
from gpio import *
import time
import os
import requests
import filecmp

# custom mpd.conf for DAC
if filecmp.cmp( '/etc/mpd.conf', '/etc/mpd.conf.gpio' ) is False:
	os.system( '/usr/bin/cp /etc/mpd.conf.gpio /etc/mpd.conf' )
	os.system( '/usr/bin/systemctl restart mpd' )
	conf = 1
else:
	conf = 0

pullup = GPIO.input( onx[ 1 ] )

data = { 'conf': conf, 'pullup': pullup }

print( json.dumps( data ) )

if pullup == off:
	# broadcast pushstream (message non-char in curl must be escaped)
	requests.post( 'http://localhost/pub?id=gpio', json={ 'state': 'ON' } )

	GPIO.output( on1, on )
	time.sleep( ond1 )
	GPIO.output( on2, on )
	time.sleep( ond2 )
	GPIO.output( on3, on )
	time.sleep( ond3 )
	GPIO.output( on4, on )

	if GPIO.input( onx[ 1 ] ) != on:
		requests.post( 'http://localhost/pub?id=gpio', json={ 'state': 'FAILED' } )
		exit()

	if gpio[ 'timer' ][ 'timer' ] != 0:
		os.system( '/usr/bin/sudo /root/gpiotimer.py &> /dev/null &' )
