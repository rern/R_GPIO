#!/usr/bin/python
import RPi.GPIO as GPIO
import json
import time
import os

with open('/srv/http/gpio.json') as jsonfile:
	gpio = json.load(jsonfile)

off = gpio['off']

off1 = int(off['off1'])
offd1 = int(off['offd1'])
off2 = int(off['off2'])
offd2 = int(off['offd2'])
off3 = int(off['off3'])
offd3 = int(off['offd3'])
off4 = int(off['off4'])

offx = [off1, off2, off3, off4]
offx = [i for i in offx if i != 0]

GPIO.setwarnings(0)
GPIO.setmode(GPIO.BOARD)
GPIO.setup(offx, GPIO.OUT)

if off1 != 0:
	GPIO.output(off1, 1)
if off2 != 0:
	time.sleep(offd1)
	GPIO.output(off2, 1)
if off3 != 0:
	time.sleep(offd2)
	GPIO.output(off3, 1)
if off4 != 0:
	time.sleep(offd3)
	GPIO.output(off4, 1)
	
print(GPIO.input(offx[1]))

os.system('/usr/bin/sudo /usr/bin/pkill -9 gpiotimer.py > /dev/null 2>&1 &')
