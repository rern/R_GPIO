#!/usr/bin/python
from gpio import *

state != OFF and exit()

# broadcast pushstream
d = dict( state='ON', delay='ond', order='onorder' )
requestData( d )

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

if GPIO.input( onenable[ 0 ] ) != ON:
	d = dict( state='FAILED !', delay=8 )
	requestData( d )
	exit()

timer > 0 and os.system( '/root/gpiotimer.py &> /dev/null &' )
