#!/usr/bin/python
from gpio import *
import time
import os
import subprocess
import requests
import filecmp

pullup = GPIO.input( onx[ 1 ] )

data = { 'pullup': pullup }

print( json.dumps( data ) )

if pullup == 1:
	# broadcast pushstream (message non-char in curl must be escaped)
	requests.post( 'http://localhost/pub?id=gpio', json={ 'state': 'ON' } )

	if on1 != 0:
		GPIO.output( on1, 0 )
	if on2 != 0:
		time.sleep( ond1 )
		GPIO.output( on2, 0 )
	if on3 != 0:
		time.sleep( ond2 )
		GPIO.output( on3, 0 )
	if on4 != 0:
		time.sleep( ond3 )
		GPIO.output( on4, 0 )

	if GPIO.input( onx[ 1 ] ) != 0:
		requests.post( 'http://localhost/pub?id=gpio', json={ 'state': 'FAILED' } )
		exit()

	if gpio[ 'timer' ][ 'timer' ] != 0:
		os.system( '/root/gpiotimer.py &> /dev/null &' )
		
	os.system( '/usr/bin/systemctl restart mpd' )
