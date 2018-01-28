#!/usr/bin/python
from gpio import *
import time
import os
import requests

print( json.dumps( { 'pullup': pullup } ) )

if pullup == ON:
	# broadcast message
	requests.post( 'http://localhost/pub?id=gpio', json={ 'state': 'OFF' } )

	if off1 != 0:
		GPIO.output( off1, OFF )
	if off2 != 0:
		time.sleep( offd1 )
		GPIO.output( off2, OFF )
	if off3 != 0:
		time.sleep( offd2 )
		GPIO.output( off3, OFF )
	if off4 != 0:
		time.sleep( offd3 )
		GPIO.output( off4, OFF )

	if GPIO.input( offx[ 1 ] ) != OFF:
		requests.post( 'http://localhost/pub?id=gpio', json={ 'state': 'FAILED' } )
		exit()

	if timer > 0:
		os.system( '/usr/bin/pkill -9 gpiotimer.py &> /dev/null' )
