#!/usr/bin/python
import RPi.GPIO as GPIO
import redis
import json

r = redis.Redis('localhost')
gpio = r.get('gpio')
gpio = gpio.decode('UTF-8')
gpio = json.loads(gpio)
on = gpio['on']
off = gpio['off']

on1 = int(on['on1'])
on2 = int(on['on2'])
on3 = int(on['on3'])
on4 = int(on['on4'])

ond1 = int(on['ond1'])
ond2 = int(on['ond2'])
ond3 = int(on['ond3'])

offd1 = int(off['offd1'])
offd2 = int(off['offd2'])
offd3 = int(off['offd3'])

onx = [on1, on2, on3, on4]
onx = [i for i in onx if i != 0]

GPIO.setwarnings(0)
GPIO.setmode(GPIO.BOARD)
GPIO.setup(onx, GPIO.OUT)

data = {'enable': gpio['enable']['enable'], 'pullup': GPIO.input(onx[1]), 'ond': ond1 + ond2 + ond3, 'offd': offd1 + offd2 + offd3}

print(json.dumps(data))
