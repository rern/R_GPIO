#!/usr/bin/python
from gpio import *
import time
import os
import subprocess
import requests
import filecmp

# set mpd output to dac
aocurrent = subprocess.Popen( [ 'redis-cli', 'get', 'ao' ], stdout=subprocess.PIPE ).communicate()[ 0 ].strip()

if aocurrent != aogpio:
	subprocess.Popen( [ 'redis-cli', 'set', 'ao', aogpio ] )
	os.system( '/usr/bin/php /srv/http/app/libs/gpiompgcfg.php' )
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
		os.system( '/root/gpiotimer.py &> /dev/null &' )
		
	if aocurrent != aogpio:
		subprocess.Popen( [ '/usr/bin/redis-cli', 'set', 'ao', aogpio ] )
		os.system( '/usr/bin/php /srv/http/app/libs/gpiompgcfg.php' )
		os.system( '/usr/bin/systemctl restart mpd' )
