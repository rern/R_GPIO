#!/usr/bin/python
from gpio import *
import time
import os
import requests

pullup = GPIO.input( offx[ 1 ] )

data = { 'conf': 0, 'pullup': pullup }

print( json.dumps( data ) )

if pullup == on:
	# broadcast message
	requests.post( 'http://localhost/pub?id=gpio', json={ 'state': 'OFF' } )

	GPIO.output( off1, off )
	time.sleep( offd1 )
	GPIO.output( off2, off )
	time.sleep( offd2 )
	GPIO.output( off3, off )
	time.sleep( offd3 )
	GPIO.output( off4, off )

	if GPIO.input( offx[ 1 ] ) != off:
		requests.post( 'http://localhost/pub?id=gpio', json={ 'state': 'FAILED' } )
		exit()

	if gpio[ 'timer' ][ 'timer' ] != 0:
		os.system( '/usr/bin/sudo /usr/bin/pkill -9 gpiotimer.py &> /dev/null' )
