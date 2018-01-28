#!/usr/bin/python
from gpio import *
import time
import os
import requests

print( json.dumps( { 'pullup': pullup } ) )

if pullup == OFF:
	# broadcast pushstream (message non-char in curl must be escaped)
	requests.post( 'http://localhost/pub?id=gpio', json={ 'state': 'ON' } )

	if on1 != 0:
		GPIO.output( on1, ON )
	if on2 != 0:
		time.sleep( ond1 )
		GPIO.output( on2, ON )
	if on3 != 0:
		time.sleep( ond2 )
		GPIO.output( on3, ON )
	if on4 != 0:
		time.sleep( ond3 )
		GPIO.output( on4, ON )

	if GPIO.input( onx[ 1 ] ) != ON:
		requests.post( 'http://localhost/pub?id=gpio', json={ 'state': 'FAILED' } )
		exit()

	if timer > 0:
		os.system( '/root/gpiotimer.py &> /dev/null &' )
			