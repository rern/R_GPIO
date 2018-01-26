#!/usr/bin/python
from gpio import *
import time
import os
import requests

pullup = GPIO.input( onx[ 1 ] )

data = { 'pullup': pullup }

print( json.dumps( data ) )

if pullup == 1:
	# broadcast pushstream (message non-char in curl must be escaped)
	requests.post( 'http://localhost/pub?id=gpio', json={ 'state': 'ON' } )


	if timer > 0:
		os.system( '/root/gpiotimer.py '+ timer +'&> /dev/null &' )
		