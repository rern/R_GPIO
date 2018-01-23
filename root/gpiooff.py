#!/usr/bin/python
from gpio import *
import time
import os
import requests

on = 1
off = 0

pullup = GPIO.input( offx[ 1 ] )

data = { 'conf': 0, 'pullup': pullup }

print( json.dumps( data ) )

if pullup == on:
	# broadcast message
	requests.post( 'http://localhost/pub?id=gpio', json={ 'state': 'OFF' } )

	if off1 != on:
		GPIO.output( off1, off )
	if off2 != on:
		time.sleep( offd1 )
		GPIO.output( off2, off )
	if off3 != on:
		time.sleep( offd2 )
		GPIO.output( off3, off )
	if off4 != on:
		time.sleep( offd3 )
		GPIO.output( off4, off )

	if GPIO.input( offx[ 1 ] ) != off:
		requests.post( 'http://localhost/pub?id=gpio', json={ 'state': 'FAILED' } )
		exit()

	if gpio[ 'timer' ][ 'timer' ] != 0:
		os.system( '/usr/bin/sudo /usr/bin/pkill -9 gpiotimer.py &> /dev/null' )
