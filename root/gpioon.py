#!/usr/bin/python
import RPi.GPIO as GPIO
import json
import time
import os
import requests
import filecmp

# custom mpd.conf for DAC
if filecmp.cmp('/etc/mpd.conf', '/etc/mpd.conf.gpio') is False:
	os.system('/usr/bin/cp /etc/mpd.conf.gpio /etc/mpd.conf')
	os.system('/usr/bin/systemctl restart mpd')
	os.system('/usr/bin/sudo /usr/bin/killall midori 2>&1; sleep 1; startx > /dev/null 2>&1 &')
	conf = 1
else:
	conf = 0

with open('/srv/http/gpio.json') as jsonfile:
	gpio = json.load(jsonfile)
	
on = gpio['on']

on1 = int(on['on1'])
ond1 = int(on['ond1'])
on2 = int(on['on2'])
ond2 = int(on['ond2'])
on3 = int(on['on3'])
ond3 = int(on['ond3'])
on4 = int(on['on4'])

onx = [on1, on2, on3, on4]
onx = [i for i in onx if i != 0]

GPIO.setwarnings(0)
GPIO.setmode(GPIO.BOARD)
GPIO.setup(onx, GPIO.OUT)

pullup = GPIO.input(onx[1])

data = {'conf': conf, 'pullup': pullup}

print(json.dumps(data))

if pullup == 0:
	exit()

# broadcast pushstream (message non-char in curl must be escaped)
requests.post("http://localhost/pub?id=gpio", json="ON")

if on1 != 0:
	GPIO.output(on1, 0)
if on2 != 0:
	time.sleep(ond1)
	GPIO.output(on2, 0)
if on3 != 0:
	time.sleep(ond2)
	GPIO.output(on3, 0)
if on4 != 0:
	time.sleep(ond3)
	GPIO.output(on4, 0)
	
if GPIO.input(onx[1]) != 0:
	requests.post("http://localhost/pub?id=gpio", json="FAILED")
	exit()

if gpio['timer']['timer'] != 0:
	os.system('/usr/bin/sudo /root/gpiotimer.py > /dev/null 2>&1 &')
