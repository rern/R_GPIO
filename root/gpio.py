#!/usr/bin/python
import RPi.GPIO as GPIO
import json
import sys
import os
import time
import requests

ON = 1
OFF = 0

with open( '/srv/http/gpio.json' ) as jsonfile:
	gpio = json.load( jsonfile )

pin  = gpio[ 'pin' ] # get data as key[ 'value' ]
pin1 = int( pin[ 'pin1' ] ) # convert to integer
pin2 = int( pin[ 'pin2' ] )
pin3 = int( pin[ 'pin3' ] )
pin4 = int( pin[ 'pin4' ] )
pinx = [ pin1, pin2, pin3, pin4 ]

GPIO.setwarnings( 0 )
GPIO.setmode( GPIO.BOARD )
GPIO.setup( pinx, GPIO.OUT )

if len( sys.argv ) > 1 and sys.argv[ 1 ] == 'set':
	os.system( '/bin/chmod g+rw /dev/gpiomem' ) # fix permission every boot
	exit()

on   = gpio[ 'on' ]
on1  = int( on[ 'on1' ] )
ond1 = int( on[ 'ond1' ] )
on2  = int( on[ 'on2' ] )
ond2 = int( on[ 'ond2' ] )
on3  = int( on[ 'on3' ] )
ond3 = int( on[ 'ond3' ] )
on4  = int( on[ 'on4' ] )
onx  = [ on1, on2, on3, on4 ]
onx  = [ i for i in onx if i != 0 ]

ondx = ond1 + ond2 + ond3

state = GPIO.input( onx[ 1 ] )

if state == ON:
	onoff = 'ON'
else:
	onoff = 'OFF'

print( json.dumps( { 'state': onoff } ) )

if len( sys.argv ) > 1 and sys.argv[ 1 ] == 'state':
	exit()

off   = gpio[ 'off' ]
off1  = int( off[ 'off1' ] )
offd1 = int( off[ 'offd1' ] )
off2  = int( off[ 'off2' ] )
offd2 = int( off[ 'offd2' ] )
off3  = int( off[ 'off3' ] )
offd3 = int( off[ 'offd3' ] )
off4  = int( off[ 'off4' ] )
offx  = [ off1, off2, off3, off4 ]
offx  = [ i for i in offx if i != 0 ]

offdx = offd1 + offd2 + offd3

timer = int( gpio[ 'timer' ][ 'timer' ] )
