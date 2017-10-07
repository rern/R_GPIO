#!/usr/bin/python
from gpio import *
import time
import os
import requests

pullup = GPIO.input(offx[1])

data = {'conf': 0, 'pullup': pullup}

print(json.dumps(data))

if pullup == 0:
	# broadcast message
	requests.post('http://localhost/pub?id=gpio', json='OFF')

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
		requests.post('http://localhost/pub?id=gpio', json='FAILED')
		exit()

	if gpio['timer']['timer'] != 0:
		os.system('/usr/bin/sudo /usr/bin/pkill -9 gpiotimer.py > /dev/null 2>&1 &')
