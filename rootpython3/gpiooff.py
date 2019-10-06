#!/usr/bin/python
from gpio import *

state != ON and exit()

# broadcast pushstream
d = dict( state='OFF', delay='offd', order='offorder' )
requestData( d )

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

if GPIO.input( offenable[ 0 ] ) != OFF:
	d = dict( state='FAILED !', delay=8 )
	requestData( d )
	exit()

timer > 0 and os.system( '/usr/bin/pkill -9 gpiotimer.py &> /dev/null' )
