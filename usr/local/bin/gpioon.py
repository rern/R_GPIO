#!/usr/bin/python
from gpio import *

state != OFF and exit()

# broadcast pushstream
pushstream( 'gpio', { 'state': True, 'delay': ond, 'order': onorder } )

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
    notifyFailed()
    exit()

timer > 0 and subprocess.Popen( [ '/usr/local/bin/gpiotimer.sh' ] )

with open( gpiofile, 'w' ) as file:
    file.write( str( timer ) )
os.chmod( gpiofile, 0o777 )
