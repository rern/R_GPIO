#!/usr/bin/python
import RPi.GPIO as GPIO
import json
import time
import os
import requests

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

pullup = GPIO.input(offx[1])

data = {'conf': 0, 'pullup': pullup}

print(json.dumps(data))

if pullup == 1:
	exit()

# broadcast message
requests.post("http://localhost/pub?id=gpio", json="OFF")

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
	
if GPIO.input(offx[1]) != 1:
	requests.post("http://localhost/pub?id=gpio", json="FAILED")
	exit()

if gpio['timer']['timer'] != 0:
	os.system('/usr/bin/sudo /usr/bin/pkill -9 gpiotimer.py > /dev/null 2>&1 &')
