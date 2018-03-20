#!/usr/bin/python
from gpio import *

if state != OFF:
	exit()
	
# broadcast pushstream (message non-char in curl must be escaped)
data = { 'state': 'ON', 'delay': ondx }
req = urllib2.Request( url, json.dumps( data ), headers = headerdata )
response = urllib2.urlopen( req )

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
	data = { 'state': 'FAILED !', 'delay': 8 }
	req = urllib2.Request( url, json.dumps( data ), headers = headerdata )
	response = urllib2.urlopen( req )
	exit()

if timer > 0:
	os.system( '/root/gpiotimer.py &> /dev/null &' )
			
