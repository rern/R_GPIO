#!/usr/bin/python
from gpio import *

if state == ON:
	# broadcast message
	data = { 'state': 'OFF', 'delay': offdx }
	req = urllib2.Request( url, json.dumps( data ), headers = headerdata )
	response = urllib2.urlopen( req )
	
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
		data = { 'state': 'FAILED !', 'delay': 8 }
		req = urllib2.Request( url, json.dumps( data ), headers = headerdata )
		response = urllib2.urlopen( req )
		exit()

	if timer > 0:
		os.system( '/usr/bin/pkill -9 gpiotimer.py &> /dev/null' )
