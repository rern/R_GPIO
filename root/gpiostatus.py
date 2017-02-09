#!/usr/bin/python
import RPi.GPIO as GPIO
import json

with open('/srv/http/gpio.json') as jsonfile:
	gpio = json.load(jsonfile)
	
on = gpio['on']
off = gpio['off']

on1 = int(on['on1'])
on2 = int(on['on2'])
on3 = int(on['on3'])
on4 = int(on['on4'])

onx = [on1, on2, on3, on4]
onx = [i for i in onx if i != 0]

GPIO.setwarnings(0)
GPIO.setmode(GPIO.BOARD)
GPIO.setup(onx, GPIO.OUT)

data = {'enable': gpio['enable']['enable'], \
	'pullup': GPIO.input(onx[1])}

print(json.dumps(data))
